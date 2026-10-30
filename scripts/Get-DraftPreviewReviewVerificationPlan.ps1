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
    throw 'draft-preview-review-repository-mismatch'
}

if ($TaskName -ne '261027_feat_draft-preview-review') {
    throw 'draft-preview-review-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'draft-preview-review-site-package-missing'
}

[pscustomobject]@{
    Scope = 'draft-preview-review'
    Commands = @('npm --prefix site run build', 'npm --prefix site test')
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test'); DisplayCommand = 'npm --prefix site test' }
    )
    Notes = @(
        'cmd.exe invokes npm through the Windows command-wrapper contract used by the durable worker.',
        'The build proves draft content remains absent from public HTML and RSS.',
        'Vitest proves the development route includes drafts and emits the review banner contract.'
    )
}
