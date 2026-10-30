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
    throw 'blog-resume-navigation-repository-mismatch'
}

if ($TaskName -ne '261030_feat_blog-resume-navigation') {
    throw 'blog-resume-navigation-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'blog-resume-navigation-site-package-missing'
}

[pscustomobject]@{
    Scope = 'blog-resume-navigation'
    Commands = @(
        'npm --prefix site run build',
        'npm --prefix site test -- --run tests/blog-resume-navigation.test.ts tests/blog-locale-surface.test.ts'
    )
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test -- --run tests/blog-resume-navigation.test.ts tests/blog-locale-surface.test.ts'); DisplayCommand = 'npm --prefix site test -- --run tests/blog-resume-navigation.test.ts tests/blog-locale-surface.test.ts' }
    )
    Notes = @(
        'The static build makes localized Resume routes and shared navigation observable.',
        'Focused Vitest files verify the navigation order and reciprocal locale metadata introduced by this plan.'
    )
}
