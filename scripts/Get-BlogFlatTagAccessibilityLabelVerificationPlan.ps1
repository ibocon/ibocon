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
if ([IO.Path]::GetFullPath($RepositoryRoot) -ne $expectedRoot) { throw 'blog-flat-tag-accessibility-label-repository-mismatch' }

$arguments = @('/d', '/s', '/c', 'npm --prefix site test -- --run tests/blog-theme.test.ts')
$display = 'npm --prefix site test -- --run tests/blog-theme.test.ts'
[pscustomobject]@{
    Scope = 'blog-flat-tag-accessibility-label'
    Commands = @($display)
    Invocations = @([pscustomobject]@{
        FilePath = 'cmd.exe'
        ArgumentList = $arguments
        DisplayCommand = $display
    })
    Notes = @('Static home-markup contract; cmd.exe invokes npm through the durable worker; no browser, deployment, or user-owned runtime required.')
}
