#!/usr/bin/env pwsh
#requires -Version 7.0

[CmdletBinding()]
param(
    [ValidateRange(1, 65535)]
    [int] $Port = 4321,

    [switch] $WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$sitePath = Join-Path $repositoryRoot 'site'
$packagePath = Join-Path $sitePath 'package.json'
if (-not (Test-Path -LiteralPath $packagePath -PathType Leaf)) {
    throw "blog-draft-preview-site-package-missing: $packagePath"
}

$npm = Get-Command npm.cmd -CommandType Application -ErrorAction Stop
$npmArguments = @('--prefix', $sitePath, 'run', 'dev', '--', '--host', '127.0.0.1', '--port', $Port)
$displayCommand = "& '$($npm.Source)' $($npmArguments -join ' ')"

if ($WhatIf) {
    Write-Output "[blog-draft-preview] $displayCommand"
    return
}

Write-Output "[blog-draft-preview] http://127.0.0.1:$Port/"
& $npm.Source @npmArguments
exit $LASTEXITCODE
