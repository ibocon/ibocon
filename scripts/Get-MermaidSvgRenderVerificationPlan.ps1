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
    throw 'mermaid-svg-render-repository-mismatch'
}

if ($TaskName -ne '261102_verify_mermaid-svg-render-V1') {
    throw 'mermaid-svg-render-scenario-required'
}

$filter = '(FullyQualifiedName~BlogMermaidRenderTests)&(Cost!=Expensive)'
$project = 'tests/Blog.PlaywrightTests/Blog.PlaywrightTests.csproj'
$arguments = @('test', $project, '--filter', $filter, '--logger', 'trx', '--results-directory', '.artifacts/blog-mermaid-render/V1')
$display = "dotnet test $project --filter `"$filter`" --logger trx --results-directory .artifacts/blog-mermaid-render/V1"
[pscustomobject]@{
    Scope = 'mermaid-svg-render-playwright'
    Commands = @($display)
    Invocations = @([pscustomobject]@{ FilePath = 'dotnet'; ArgumentList = $arguments; DisplayCommand = $display })
    Notes = @(
        'Focused BlogMermaidRenderTests selector; Edge-Debug localhost:9222 CDP; only created page is closed.',
        'Requires the local astro dev server on 127.0.0.1:4321 serving the draft incident post.'
    )
}
