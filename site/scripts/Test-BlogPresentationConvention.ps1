[CmdletBinding()]
param(
    [string] $SiteRoot = (Join-Path $PSScriptRoot '..'),
    [string] $ContentRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-presentation-policy.json'),
    [string] $GuardPath = (Join-Path $PSScriptRoot '../../lib/Garden.Harness/src/markdown/guards/Test-TechnicalBlogPresentationGuard.ps1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $GuardPath -PathType Leaf)) {
    throw "blog-presentation-guard-missing: $GuardPath"
}

$global:LASTEXITCODE = 0
& $GuardPath -SiteRoot ([IO.Path]::GetFullPath($SiteRoot)) -PolicyPath ([IO.Path]::GetFullPath($PolicyPath)) -ContentRoot ([IO.Path]::GetFullPath($ContentRoot))
$GuardExitCode = $LASTEXITCODE

$Policy = Get-Content -LiteralPath $PolicyPath -Raw -Encoding utf8 | ConvertFrom-Json
$ParticipantLimit = $Policy.diagrams.maxSequenceParticipants
if ($null -eq $ParticipantLimit) {
    exit 0
}

if ([int] $ParticipantLimit -lt 1) {
    Write-Output "::error::technical-blog-presentation-policy-sequence-participant-limit-invalid: $PolicyPath"
    exit 1
}

$Violations = [Collections.Generic.List[string]]::new()
foreach ($Document in @(Get-ChildItem -LiteralPath $ContentRoot -File -Filter '*.md' | Sort-Object Name)) {
    $Content = Get-Content -LiteralPath $Document.FullName -Raw -Encoding utf8
    $Parts = [regex]::Match($Content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
    if (-not $Parts.Success -or $Parts.Groups['frontMatter'].Value -notmatch '(?m)^authoringVersion:\s*1\s*$') {
        continue
    }

    $DiagramNumber = 0
    foreach ($Diagram in [regex]::Matches($Parts.Groups['body'].Value, '(?ms)^```mermaid\s*\r?\n(?<source>.*?)^```')) {
        $DiagramNumber++
        $Source = $Diagram.Groups['source'].Value
        if ($Source -notmatch '(?m)^\s*sequenceDiagram\s*$') {
            continue
        }

        $Participants = @([regex]::Matches($Source, '(?m)^\s*(?:participant|actor)\s+') | ForEach-Object { $_.Value })
        if ($Participants.Count -gt [int] $ParticipantLimit) {
            $Violations.Add("technical-blog-presentation-diagram-sequence-participant-limit: $($Document.Name)#diagram-$DiagramNumber")
        }
    }
}

if ($Violations.Count -gt 0) {
    $Violations | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

exit $GuardExitCode
