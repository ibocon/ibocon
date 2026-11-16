param(
    [string] $ReadmePath = (Join-Path $PSScriptRoot '../../README.md'),
    [string] $ResumePath = (Join-Path $PSScriptRoot '../../resume/resume-yegun-kim.md')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# README 라벨 중 이력서의 표기와 다른 것만 정의한다.
$script:LabelAliases = @{
    '.NET MAUI'        = '.NET MAUI Blazor Hybrid'
    'Material 3'       = 'Garden.Razor (Material 3)'
    'Roslyn Analyzers' = 'Roslyn 애널라이저'
    'Claude Code'      = 'Garden.Harness (Claude/Codex/OpenCode/Gemini)'
    'Codex'            = 'Garden.Harness (Claude/Codex/OpenCode/Gemini)'
    'OpenCode'         = 'Garden.Harness (Claude/Codex/OpenCode/Gemini)'
    'Gemini CLI'       = 'Garden.Harness (Claude/Codex/OpenCode/Gemini)'
}

function Get-ReadmeBadges {
    param([Parameter(Mandatory)][string] $Markdown)

    $section = [regex]::Match($Markdown, '(?s)## 🛠 기술 스택.*?(?=\r?\n---)').Value
    foreach ($match in [regex]::Matches($section, '!\[(?<label>[^\]]+)\]\((?<url>[^)]+)\)')) {
        [pscustomobject]@{ Label = $match.Groups['label'].Value; Url = $match.Groups['url'].Value }
    }
}

function Get-ResumeTechStack {
    param([Parameter(Mandatory)][string] $Markdown)

    $section = [regex]::Match($Markdown, '(?s)## 기술 스택.*?(?=\r?\n---)').Value
    return [regex]::Matches($section, '`(?<name>[^`]+)`') | ForEach-Object { $_.Groups['name'].Value }
}

function Test-TechStackBadges {
    param(
        [Parameter(Mandatory)][object[]] $Badges,
        [Parameter(Mandatory)][string[]] $ResumeStack
    )

    $problems = [System.Collections.Generic.List[string]]::new()

    foreach ($badge in $Badges) {
        $path = ($badge.Url -split '\?')[0]
        if ($path -match '#') {
            $problems.Add("배지 '$($badge.Label)' URL에 이스케이프되지 않은 '#'가 있다.")
        }

        $expected = if ($script:LabelAliases.ContainsKey($badge.Label)) { $script:LabelAliases[$badge.Label] } else { $badge.Label }
        if ($expected -notin $ResumeStack) {
            $problems.Add("배지 '$($badge.Label)'가 이력서 기술 스택에 없다.")
        }
    }

    foreach ($duplicate in ($Badges | Group-Object Label | Where-Object Count -gt 1)) {
        $problems.Add("배지 '$($duplicate.Name)'가 중복된다.")
    }

    return $problems
}

if ($MyInvocation.InvocationName -ne '.') {
    $badges = @(Get-ReadmeBadges -Markdown (Get-Content -Raw -Path $ReadmePath))
    $stack = @(Get-ResumeTechStack -Markdown (Get-Content -Raw -Path $ResumePath))
    $problems = @(Test-TechStackBadges -Badges $badges -ResumeStack $stack)

    $problems | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit ($problems.Count -gt 0 ? 1 : 0)
}
