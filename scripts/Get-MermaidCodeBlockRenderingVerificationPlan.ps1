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
    throw 'mermaid-code-block-rendering-repository-mismatch'
}

if ($TaskName -ne '261027_fix_mermaid-code-block-rendering') {
    throw 'mermaid-code-block-rendering-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'mermaid-code-block-rendering-site-package-missing'
}

[pscustomobject]@{
    Scope = 'mermaid-code-block-rendering'
    Commands = @('npm --prefix site run build', 'npm --prefix site test')
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test'); DisplayCommand = 'npm --prefix site test' }
    )
    Notes = @(
        'cmd.exe invokes npm through the Windows command-wrapper contract used by the durable worker.',
        'The Astro build preserves the production draft exclusion boundary.',
        'Vitest verifies Mermaid source normalization and the existing draft preview contract.'
    )
}
