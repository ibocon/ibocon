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
    throw 'mermaid-shiki-language-selector-repository-mismatch'
}

if ($TaskName -ne '261101_fix_mermaid-shiki-language-selector') {
    throw 'mermaid-shiki-language-selector-task-required'
}

if (-not (Test-Path -LiteralPath (Join-Path $RepositoryRoot 'site/package.json') -PathType Leaf)) {
    throw 'mermaid-shiki-language-selector-site-package-missing'
}

[pscustomobject]@{
    Scope = 'mermaid-shiki-language-selector'
    Commands = @('npm --prefix site run build', 'npm --prefix site test')
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site run build'); DisplayCommand = 'npm --prefix site run build' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/s', '/c', 'npm --prefix site test'); DisplayCommand = 'npm --prefix site test' }
    )
    Notes = @(
        'cmd.exe invokes npm through the Windows command-wrapper contract used by the durable worker.',
        'The Astro build preserves the production draft exclusion boundary.',
        'Vitest verifies the Shiki data-language selector contract and the preserved normalization and render calls.'
    )
}
