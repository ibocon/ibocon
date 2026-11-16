[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $GlossaryPath = (Join-Path $PSScriptRoot '../src/data/glossary.json'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-authoring-policy.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-Violation {
    param([Collections.Generic.List[string]] $Violations, [string] $Code, [string] $Path)

    $Violations.Add("${Code}: $Path")
}

function Get-MaskedBody {
    param([string] $Body)

    # 코드 블록, 인라인 코드, HTML 주석은 원문 그대로 두므로 같은 길이의 공백으로 가려 줄 번호와 위치를 보존한다.
    $mask = [Text.RegularExpressions.MatchEvaluator] { param($match) [regex]::Replace($match.Value, '[^\r\n]', ' ') }
    $masked = [regex]::Replace($Body, '(?ms)^[ \t]*(?<fence>`{3,}|~{3,}).*?^[ \t]*\k<fence>[ \t]*\r?$', $mask)
    $masked = [regex]::Replace($masked, '`[^`\r\n]*`', $mask)

    return [regex]::Replace($masked, '(?s)<!--.*?-->', $mask)
}

function Get-LineNumber {
    param([string] $Text, [int] $Index)

    return @($Text.Substring(0, $Index) -split "`r?`n").Count
}

function Test-Glossary {
    param([object] $Glossary, [Collections.Generic.List[string]] $Violations)

    $ids = @{}
    $surfaces = @{}
    foreach ($term in $Glossary.terms) {
        if ($term.id -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$' -or $ids.ContainsKey($term.id)) {
            Add-Violation -Violations $Violations -Code 'blog-terminology-glossary-invalid' -Path "id:$($term.id)"
        }

        $ids[$term.id] = $true
        foreach ($surface in @($term.term) + @($term.forbidden)) {
            $key = ([string] $surface).Trim().ToLowerInvariant()
            if ([string]::IsNullOrWhiteSpace($key) -or ($surfaces.ContainsKey($key) -and $surfaces[$key] -ne $term.id)) {
                Add-Violation -Violations $Violations -Code 'blog-terminology-glossary-invalid' -Path "surface:$surface"
            }

            $surfaces[$key] = $term.id
        }

        if ([string]::IsNullOrWhiteSpace($term.definition)) {
            Add-Violation -Violations $Violations -Code 'blog-terminology-glossary-invalid' -Path "definition:$($term.id)"
        }
    }
}

function Get-FirstProseOccurrence {
    param([object[]] $Occurrences, [string] $Scan, [object[]] $Links, [string] $TermId)

    # 제목 줄과 다른 주소로 가는 링크 안의 등장은 첫 등장으로 세지 않는다.
    $scanLines = $Scan -split "`r?`n"
    return $Occurrences | Where-Object {
        $candidate = $_
        $lineText = $scanLines[(Get-LineNumber -Text $Scan -Index $candidate.Index) - 1]
        $insideOtherLink = @($Links | Where-Object {
            $_.Groups['href'].Value -ne "/glossary/#$TermId" -and
            $candidate.Index -ge $_.Groups['text'].Index -and
            $candidate.Index -lt ($_.Groups['text'].Index + $_.Groups['text'].Length)
        }).Count -gt 0

        ($lineText -notmatch '^\s*#') -and (-not $insideOtherLink)
    } | Select-Object -First 1
}

$glossary = Get-Content -Raw -LiteralPath ([IO.Path]::GetFullPath($GlossaryPath)) | ConvertFrom-Json
$policy = Get-Content -Raw -LiteralPath ([IO.Path]::GetFullPath($PolicyPath)) | ConvertFrom-Json
$violations = [Collections.Generic.List[string]]::new()
Test-Glossary -Glossary $glossary -Violations $violations
$validIds = @($glossary.terms | ForEach-Object { $_.id })
$checked = 0

foreach ($post in Get-ChildItem -LiteralPath ([IO.Path]::GetFullPath($BlogRoot)) -File -Filter '*.md' | Sort-Object Name) {
    $content = Get-Content -Raw -LiteralPath $post.FullName
    $match = [regex]::Match($content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
    if (-not $match.Success -or $match.Groups['frontMatter'].Value -notmatch "(?m)^authoringVersion:\s*$($policy.authoringVersion)\s*$") {
        continue
    }

    $checked++
    $masked = Get-MaskedBody -Body $match.Groups['body'].Value
    $links = @([regex]::Matches($masked, '\[(?<text>[^\]\r\n]*)\]\((?<href>[^)\s]*)\)'))
    # 링크 주소는 글자 검사에서 제외한다. 길이를 보존해 위치가 어긋나지 않게 한다.
    $scan = [regex]::Replace($masked, '\]\([^)\s]*\)', { param($m) ']' + (' ' * ($m.Length - 1)) })

    foreach ($link in $links) {
        $anchor = [regex]::Match($link.Groups['href'].Value, '^/glossary/#(?<id>.*)$')
        if ($anchor.Success -and $validIds -notcontains $anchor.Groups['id'].Value) {
            Add-Violation -Violations $violations -Code 'blog-terminology-link-target-unknown' -Path "$($post.Name):$(Get-LineNumber -Text $masked -Index $link.Index)"
        }
    }

    foreach ($term in $glossary.terms) {
        foreach ($variant in $term.forbidden) {
            $index = $scan.IndexOf([string] $variant, [StringComparison]::Ordinal)
            if ($index -ge 0) {
                Add-Violation -Violations $violations -Code 'blog-terminology-variant-term' -Path "$($post.Name):$(Get-LineNumber -Text $scan -Index $index) [$($term.id)]"
            }
        }

        # 표준 표기와 대소문자·띄어쓰기만 다른 변종을 찾는다.
        $pattern = [regex]::Escape([string] $term.term) -replace '\\ ', '\s*'
        # 영문 약어는 다른 영어 단어 안(platform의 orm 등)에서 찾지 않도록 영숫자 경계를 요구한다.
        if ($term.term -match '^[A-Za-z0-9]') {
            $pattern = '(?<![A-Za-z0-9])' + $pattern
        }

        if ($term.term -match '[A-Za-z0-9]$') {
            $pattern = $pattern + '(?![A-Za-z0-9])'
        }

        $occurrences = @([regex]::Matches($scan, $pattern, 'IgnoreCase'))
        foreach ($occurrence in $occurrences) {
            if ($occurrence.Value -cne $term.term) {
                Add-Violation -Violations $violations -Code 'blog-terminology-case-variant' -Path "$($post.Name):$(Get-LineNumber -Text $scan -Index $occurrence.Index) [$($term.id)]"
            }
        }

        $first = Get-FirstProseOccurrence -Occurrences $occurrences -Scan $scan -Links $links -TermId $term.id
        if ($null -ne $first) {
            $linked = @($links | Where-Object {
                $_.Groups['href'].Value -eq "/glossary/#$($term.id)" -and
                $first.Index -ge $_.Groups['text'].Index -and
                $first.Index -lt ($_.Groups['text'].Index + $_.Groups['text'].Length)
            })
            if ($linked.Count -eq 0) {
                Add-Violation -Violations $violations -Code 'blog-terminology-link-missing' -Path "$($post.Name):$(Get-LineNumber -Text $scan -Index $first.Index) [$($term.id)]"
            }
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[blog-terminology] OK posts=$checked terms=$(@($glossary.terms).Count)"
