[CmdletBinding()]
param(
    [string] $ResumeRoot = (Join-Path $PSScriptRoot '../../resume'),
    [string] $GlossaryPath = (Join-Path $PSScriptRoot '../../resume/glossary.md')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-Violation {
    param([Collections.Generic.List[string]] $Violations, [string] $Code, [string] $Path)

    $Violations.Add("${Code}: $Path")
}

function Get-LineNumber {
    param([string] $Text, [int] $Index)

    return @($Text.Substring(0, $Index) -split "`r?`n").Count
}

function Get-GlossaryTerms {
    param([string] $Content)

    $terms = [Collections.Generic.List[object]]::new()
    foreach ($line in $Content -split "`r?`n") {
        $match = [regex]::Match($line, '^\|\s*(?<id>[a-z][a-z0-9-]*)\s*\|\s*(?<term>[^|]+?)\s*\|\s*(?<forbidden>[^|]+?)\s*\|\s*$')
        if (-not $match.Success) {
            continue
        }

        $terms.Add([pscustomobject]@{
            Id = $match.Groups['id'].Value
            Term = $match.Groups['term'].Value.Trim()
            Forbidden = @($match.Groups['forbidden'].Value -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        })
    }

    return $terms
}

$resumePath = [IO.Path]::GetFullPath($ResumeRoot)
$glossaryFullPath = [IO.Path]::GetFullPath($GlossaryPath)
$violations = [Collections.Generic.List[string]]::new()

if (-not (Test-Path -LiteralPath $glossaryFullPath)) {
    Add-Violation -Violations $violations -Code 'resume-terminology-glossary-missing' -Path $glossaryFullPath
}
else {
    $terms = @(Get-GlossaryTerms -Content (Get-Content -Raw -LiteralPath $glossaryFullPath))
    if ($terms.Count -eq 0) {
        Add-Violation -Violations $violations -Code 'resume-terminology-glossary-invalid' -Path $glossaryFullPath
    }
}

if (-not (Test-Path -LiteralPath $resumePath)) {
    Add-Violation -Violations $violations -Code 'resume-terminology-root-missing' -Path $resumePath
}
elseif ($violations.Count -eq 0) {
    $files = Get-ChildItem -LiteralPath $resumePath -File -Filter '*.md' | Where-Object {
        $_.Name -eq 'resume-yegun-kim.md' -or $_.Name -eq 'resume-document-index.md' -or $_.Name -like 'project-*.md'
    }
    foreach ($file in $files) {
        $content = Get-Content -Raw -LiteralPath $file.FullName
        foreach ($term in $terms) {
            foreach ($forbidden in $term.Forbidden) {
                $index = $content.IndexOf($forbidden, [StringComparison]::OrdinalIgnoreCase)
                if ($index -ge 0) {
                    Add-Violation -Violations $violations -Code 'resume-terminology-forbidden-term' -Path "$($file.Name):$(Get-LineNumber -Text $content -Index $index) [$($term.Id)]"
                }
            }
        }

        $offset = 0
        foreach ($line in $content -split "`r?`n") {
            $label = $line -match '^\s*#{1,6}\s+' -or $line -match '^\s*<page\b' -or $line -match '^\s*<td>\*\*'
            $withoutCode = [regex]::Replace($line, '`[^`]*`', '')
            if ($label -and $withoutCode -match '\([^)]*\)') {
                $inner = $Matches[0].Trim('(', ')').Trim()
                if ($inner -match '[^0-9.\s,~–-]') {
                    Add-Violation -Violations $violations -Code 'resume-presentation-parenthetical-label' -Path "$($file.Name):$(Get-LineNumber -Text $content -Index $offset)"
                }
            }

            $offset += $line.Length + 1
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[resume-terminology] OK files=$(@(Get-ChildItem -LiteralPath $resumePath -File -Filter '*.md').Count) terms=$($terms.Count)"
