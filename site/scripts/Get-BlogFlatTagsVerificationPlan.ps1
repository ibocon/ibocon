[CmdletBinding()]
param(
    [string[]] $ChangedPaths = @(),
    [string] $ChangedPathBase = '.',
    [string] $TaskName = '',
    [string] $RepositoryRoot = '',
    [switch] $IncludeExpensive,
    [switch] $ChangedProjectsOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$null = @($ChangedPaths).Count
$null = $ChangedPathBase.Length
$null = $TaskName.Length
$null = $IncludeExpensive.IsPresent
$null = $ChangedProjectsOnly.IsPresent

$testCommand = 'cd /d site && npm exec vitest run tests/blog-search.test.ts tests/blog-theme.test.ts tests/migrate-tistory.test.ts tests/normalize-blog-tags.test.ts'
$buildCommand = 'cd /d site && npm run build'

[pscustomobject]@{
    Scope = 'blog-flat-tags'
    Commands = @($testCommand, $buildCommand)
    Invocations = @(
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/c', $testCommand); DisplayCommand = $testCommand; OutcomeProtocol = 'native-exit-v1' },
        [pscustomobject]@{ FilePath = 'cmd.exe'; ArgumentList = @('/d', '/c', $buildCommand); DisplayCommand = $buildCommand; OutcomeProtocol = 'native-exit-v1' }
    )
}
