[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-authoring-policy.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-Violation {
    param([Collections.Generic.List[string]] $Violations, [string] $Code, [string] $Path)

    $Violations.Add("${Code}: $Path")
}

function Get-PostParts {
    param([string] $Content, [string] $Path)

    $match = [regex]::Match($Content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
    if (-not $match.Success) {
        throw "blog-authoring-frontmatter-missing: $Path"
    }

    return [pscustomobject]@{
        FrontMatter = $match.Groups['frontMatter'].Value
        Body = $match.Groups['body'].Value
    }
}

function Get-FrontMatterValue {
    param([string] $FrontMatter, [string] $Name)

    $match = [regex]::Match($FrontMatter, "(?m)^$([regex]::Escape($Name)):\s*(?<value>.*?)\s*$")
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups['value'].Value.Trim().Trim('"', "'")
}

function Test-Heading {
    param([string] $Body, [string] $Heading)

    return [regex]::IsMatch($Body, "(?m)^##\s+$([regex]::Escape($Heading))(\s*:.*)?\s*$")
}

function Test-RoleHeading {
    param([string] $Body, [object] $Policy, [string] $Role)

    $aliases = @($Policy.sectionAliases.$Role)
    if ($aliases.Count -eq 0) {
        throw "blog-authoring-policy-section-alias-missing: $Role"
    }

    return @($aliases | Where-Object { Test-Heading -Body $Body -Heading ([string] $_) }).Count -gt 0
}

function Get-PoliteEndingLine {
    param([string] $Body)

    # 문장 끝(마침표 직전 또는 줄 끝)에 오는 존댓말 종결만 찾는다. 코드 블록, 인라인 코드, 링크 주소, HTML 주석은 원문 그대로 두므로 검사하지 않는다.
    # PowerShell은 곡선 작은따옴표(U+2019)를 따옴표로 해석하므로 문자 코드로 조립한다.
    $closers = '"' + "'" + [char] 0x201D + [char] 0x2019 + ')\]*_~'
    $terminator = '(?=[' + $closers + ']*(?:[.!?' + [char] 0x2026 + ']|\s*$))'
    $formal = [regex]::new("(?<syllable>[가-힣])니다$terminator")
    $informal = [regex]::new("(?:해요|세요|예요|에요|네요|군요|까요|어요|아요|죠)$terminator")
    $found = [Collections.Generic.List[int]]::new()
    $inFence = $false
    $lines = $Body -split "`r?`n"
    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match '^[ 	]*(`{3,}|~{3,})') {
            $inFence = -not $inFence
            continue
        }

        if ($inFence) {
            continue
        }

        $text = $lines[$index] -replace '`[^`]*`', '' -replace '<!--.*?-->', '' -replace '\]\([^)]*\)', ']'
        $isPolite = $informal.IsMatch($text)
        foreach ($match in $formal.Matches($text)) {
            # 받침 ㅂ(종성 17)이 붙은 음절 뒤의 "니다"만 존댓말이다. "아니다"는 한다체라서 제외한다.
            if ((([int][char] $match.Groups['syllable'].Value) - 0xAC00) % 28 -eq 17) {
                $isPolite = $true
            }
        }

        if ($isPolite) {
            $found.Add($index + 1)
        }
    }

    return $found.ToArray()
}

$resolvedBlogRoot = [IO.Path]::GetFullPath($BlogRoot)
$resolvedPolicyPath = [IO.Path]::GetFullPath($PolicyPath)
$policy = Get-Content -Raw -LiteralPath $resolvedPolicyPath | ConvertFrom-Json
$violations = [Collections.Generic.List[string]]::new()
$validatedCount = 0

foreach ($post in Get-ChildItem -LiteralPath $resolvedBlogRoot -File -Filter '*.md' | Sort-Object Name) {
    $parts = Get-PostParts -Content (Get-Content -Raw -LiteralPath $post.FullName) -Path $post.Name
    $version = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'authoringVersion'
    if ($version -ne [string] $policy.authoringVersion) {
        continue
    }

    $validatedCount++
    $audience = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'audience'
    $articleType = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'articleType'
    $description = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'description'

    if ([string]::IsNullOrWhiteSpace($audience)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-audience-missing' -Path $post.Name
    }

    if ([string]::IsNullOrWhiteSpace($articleType)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-article-type-missing' -Path $post.Name
        continue
    }

    if (-not ($policy.articleTypes.PSObject.Properties.Name -contains $articleType)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-article-type-invalid' -Path $post.Name
        continue
    }

    if ([string]::IsNullOrWhiteSpace($description) -or
        $description.Length -lt [int] $policy.description.minLength -or
        $description.Length -gt [int] $policy.description.maxLength) {
        Add-Violation -Violations $violations -Code 'blog-authoring-description-length-invalid' -Path $post.Name
    }

    $requiredRoles = @($policy.commonSections) + @($policy.articleTypes.$articleType)
    foreach ($role in $requiredRoles) {
        if (-not (Test-RoleHeading -Body $parts.Body -Policy $policy -Role ([string] $role))) {
            Add-Violation -Violations $violations -Code 'blog-authoring-required-section-missing' -Path "$($post.Name)#$role"
        }
    }

    if ($null -ne $policy.PSObject.Properties['readingTime']) {
        # 코드 블록(mermaid 포함)은 읽는 글이 아니라 참고 자료라서 분량에서 뺀다.
        # CRLF 파일에서는 줄 끝 `$`가 `\r` 앞에서 맞지 않아 코드 블록이 남으므로 줄바꿈을 먼저 통일한다.
        $prose = [regex]::Replace(($parts.Body -replace '\r\n', "`n"),'(?ms)^[ 	]*(?<fence>`{3,}|~{3,}).*?^[ 	]*\k<fence>[ 	]*$', '')
        $charCount = ($prose -replace '\s', '').Length
        $charLimit = [int] $policy.readingTime.maxMinutes * [int] $policy.readingTime.charsPerMinute
        if ($charCount -gt $charLimit) {
            Add-Violation -Violations $violations -Code 'blog-authoring-reading-time-exceeded' -Path $post.Name
        }
    }

    foreach ($image in [regex]::Matches($parts.Body, '!\[(?<alt>[^\]]*)\]\([^\)]*\)')) {
        if ([string]::IsNullOrWhiteSpace($image.Groups['alt'].Value)) {
            Add-Violation -Violations $violations -Code 'blog-authoring-image-alt-missing' -Path $post.Name
        }
    }

    if ($null -ne $policy.PSObject.Properties['forbiddenPhrases']) {
        # 조사 경로와 문서 이력은 독자의 판단에 쓰이지 않는다. 코드 블록은 참고 자료라서 뺀다. 문장은 출력하지 않고 code만 보고한다.
        $proseForPhrases = [regex]::Replace($parts.Body, '(?ms)^[ 	]*(?<fence>`{3,}|~{3,}).*?^[ 	]*\k<fence>[ 	]*$', '')
        foreach ($phrase in @($policy.forbiddenPhrases)) {
            if ([regex]::IsMatch($proseForPhrases, [string] $phrase.pattern)) {
                Add-Violation -Violations $violations -Code 'blog-authoring-forbidden-phrase' -Path "$($post.Name)#$($phrase.code)"
            }
        }
    }

    if ($null -ne $policy.PSObject.Properties['tone'] -and [string] $policy.tone.style -eq 'plain-written') {
        # front matter의 description은 검색 결과 문장이라 검사하지 않고 본문만 본다.
        $bodyStartLine = @($parts.FrontMatter -split "`r?`n").Count + 2
        foreach ($lineNumber in Get-PoliteEndingLine -Body $parts.Body) {
            Add-Violation -Violations $violations -Code 'blog-authoring-tone-polite-ending' -Path "$($post.Name):$($bodyStartLine + $lineNumber)"
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[blog-authoring-convention] OK posts=$validatedCount"
