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
    throw 'postfix-case-study-repository-mismatch'
}

if ($TaskName -ne '261027_feat_postfix-open-relay-case-study') {
    throw 'postfix-case-study-task-required'
}

$sitePath = Join-Path $RepositoryRoot 'site'
if (-not (Test-Path -LiteralPath (Join-Path $sitePath 'package.json') -PathType Leaf)) {
    throw 'postfix-case-study-site-package-missing'
}

$buildArguments = @('/d', '/s', '/c', 'npm --prefix site run build')
$testArguments = @('/d', '/s', '/c', 'npm --prefix site test')

[pscustomobject]@{
    Scope = 'postfix-open-relay-case-study'
    Commands = @(
        'npm --prefix site run build',
        'npm --prefix site test'
    )
    Invocations = @(
        [pscustomobject]@{
            FilePath = 'cmd.exe'
            ArgumentList = $buildArguments
            DisplayCommand = 'npm --prefix site run build'
        },
        [pscustomobject]@{
            FilePath = 'cmd.exe'
            ArgumentList = $testArguments
            DisplayCommand = 'npm --prefix site test'
        }
    )
    Notes = @(
        'cmd.exe invokes npm through the Windows command-wrapper contract used by the durable worker.',
        'The Astro build verifies the draft content parses without publishing it.',
        'Vitest verifies that the draft remains absent from public HTML and RSS.'
    )
}
