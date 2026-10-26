[CmdletBinding()]
param(
    [string[]] $ChangedPaths = @(),
    [string] $ChangedPathBase = '.',
    [string] $RepositoryRoot = '',
    [string] $TaskName = '',
    [switch] $IncludeExpensive,
    [switch] $ChangedProjectsOnly
)

$ErrorActionPreference = 'Stop'
$expectedRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
if ([IO.Path]::GetFullPath($RepositoryRoot) -ne $expectedRoot) {
    throw 'blog-long-lived-page-update-repository-mismatch'
}

if ($TaskName -ne '261026_fix_blog-long-lived-page-update') {
    throw 'blog-long-lived-page-update-task-required'
}

$nodeRoot = Join-Path $env:ProgramFiles 'nodejs'
$nodeExecutable = Join-Path $nodeRoot 'node.exe'
$npmCliPath = Join-Path $nodeRoot 'node_modules/npm/bin/npm-cli.js'
if (-not (Test-Path -LiteralPath $nodeExecutable) -or -not (Test-Path -LiteralPath $npmCliPath)) {
    throw 'blog-long-lived-page-update-node-runtime-unavailable'
}

$arguments = @($npmCliPath, '--prefix', 'site', 'test', '--', '--run', 'tests/blog-theme.test.ts')
$display = 'npm --prefix site test -- --run tests/blog-theme.test.ts'
[pscustomobject]@{
    Scope = 'blog-long-lived-page-update'
    Commands = @($display)
    Invocations = @([pscustomobject]@{
        FilePath = $nodeExecutable
        ArgumentList = $arguments
        DisplayCommand = $display
    })
    Notes = @('Repository-bound Vitest route for deployment update detection.')
}
