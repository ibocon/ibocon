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
    throw 'draft-preview-pwsh-launcher-repository-mismatch'
}

if ($TaskName -ne '261027_feat_draft-preview-pwsh-launcher') {
    throw 'draft-preview-pwsh-launcher-task-required'
}

$launcherPath = Join-Path $RepositoryRoot 'scripts/Start-BlogDraftPreview.ps1'
if (-not (Test-Path -LiteralPath $launcherPath -PathType Leaf)) {
    throw 'draft-preview-pwsh-launcher-script-missing'
}

[pscustomobject]@{
    Scope = 'draft-preview-pwsh-launcher'
    Commands = @('pwsh -NoProfile -File scripts/Start-BlogDraftPreview.ps1 -WhatIf')
    Invocations = @(
        [pscustomobject]@{
            FilePath = 'pwsh.exe'
            ArgumentList = @('-NoProfile', '-File', $launcherPath, '-WhatIf')
            DisplayCommand = 'pwsh -NoProfile -File scripts/Start-BlogDraftPreview.ps1 -WhatIf'
        }
    )
    Notes = @(
        'The WhatIf contract verifies the resolved npm.cmd command without starting an Astro process.',
        'Interactive browser inspection remains in the existing user verify plan.'
    )
}
