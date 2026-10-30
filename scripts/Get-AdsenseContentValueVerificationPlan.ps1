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
    throw 'adsense-content-value-repository-mismatch'
}

if ($TaskName -ne '261030_fix_blog-trust-release-gate') {
    throw 'blog-trust-release-gate-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'adsense-content-value-site-package-missing'
}

[pscustomobject]@{
    Scope = 'blog-trust-release-gate'
    Commands = @('npm --prefix site run build', 'npm --prefix site test -- --run tests/blog-trust-surface.test.ts')
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test -- --run tests/blog-trust-surface.test.ts'); DisplayCommand = 'npm --prefix site test -- --run tests/blog-trust-surface.test.ts' }
    )
    Notes = @(
        'The static build makes trust pages, navigation, and publication metadata observable.',
        'The focused Vitest file verifies only the trust surface introduced by this plan.'
    )
}
