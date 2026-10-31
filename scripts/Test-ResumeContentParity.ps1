#!/usr/bin/env pwsh
#requires -Version 7.0

[CmdletBinding()]
param(
    [string] $ResumePath = (Join-Path $PSScriptRoot '../resume/resume-yegun-kim.md'),
    [string] $NavigationPath = (Join-Path $PSScriptRoot '../resume/resume-navigation.json'),
    [string] $ReadbackPath = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$resume = Get-Content -LiteralPath $ResumePath -Raw
$navigation = Get-Content -LiteralPath $NavigationPath -Raw | ConvertFrom-Json
$requiredHeadings = @('대표 역량', '경력', '주요 프로젝트 바로가기', '전체 도메인 지도', '기술 스택', '학력')

foreach ($heading in $requiredHeadings) {
    if ($resume -notmatch [regex]::Escape("## $heading")) { throw "resume-section-missing:$heading" }
}

if (@($navigation.sections).Count -ne 7) { throw 'resume-navigation-section-count-invalid' }
if (@($navigation.projects).Count -ne 4) { throw 'resume-navigation-project-count-invalid' }
if (@($navigation.domains).Count -ne 10) { throw 'resume-navigation-domain-count-invalid' }
foreach ($entry in @($navigation.sections + $navigation.projects + $navigation.domains)) {
    if ([string]::IsNullOrWhiteSpace([string] $entry.url) -and [string]::IsNullOrWhiteSpace([string] $entry.notionUrl)) { throw 'resume-navigation-notion-url-missing' }
}

if (-not [string]::IsNullOrWhiteSpace($ReadbackPath)) {
    $readback = Get-Content -LiteralPath $ReadbackPath -Raw
    foreach ($heading in $requiredHeadings) {
        if ($readback -notmatch [regex]::Escape("## $heading")) { throw "notion-readback-section-missing:$heading" }
    }
}

Write-Output '[resume-content-parity] OK'
