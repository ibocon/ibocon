#!/usr/bin/env pwsh
#requires -Version 7.0

[CmdletBinding()]
param(
    [string[]] $ChangedPaths = @(),
    [string] $ChangedPathBase = '.',
    [string] $RepositoryRoot = '',
    [string] $TaskName = '',
    [switch] $IncludeExpensive,
    [switch] $ChangedProjectsOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$expectedRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ([IO.Path]::GetFullPath($RepositoryRoot) -ne $expectedRoot) {
    throw 'resume-notion-sync-repository-mismatch'
}

if ($TaskName -ne '261030_feat_resume-notion-sync') {
    throw 'resume-notion-sync-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'resume-notion-sync-site-package-missing'
}

[pscustomobject]@{
    Scope = 'resume-notion-sync'
    Commands = @(
        'pwsh -NoProfile -File scripts/Publish-ResumeToNotion.ps1',
        'npm --prefix site run build',
        'npm --prefix site test -- --run tests/resume-content-parity.test.ts',
        'pwsh -NoProfile -File scripts/Test-ResumeContentParity.ps1'
    )
    Invocations = @(
        [pscustomobject]@{ FilePath = 'pwsh'; ArgumentList = @('-NoProfile', '-File', 'scripts/Publish-ResumeToNotion.ps1'); DisplayCommand = 'pwsh -NoProfile -File scripts/Publish-ResumeToNotion.ps1' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test -- --run tests/resume-content-parity.test.ts'); DisplayCommand = 'npm --prefix site test -- --run tests/resume-content-parity.test.ts' },
        [pscustomobject]@{ FilePath = 'pwsh'; ArgumentList = @('-NoProfile', '-File', 'scripts/Test-ResumeContentParity.ps1'); DisplayCommand = 'pwsh -NoProfile -File scripts/Test-ResumeContentParity.ps1' }
    )
    Notes = @(
        'The payload generator is local-only and does not mutate Notion.',
        'The static build precedes the focused Vitest assertion over generated HTML anchors and Notion links.',
        'Remote Notion read-back belongs to the separate verify plan.'
    )
}
