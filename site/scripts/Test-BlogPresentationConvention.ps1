[CmdletBinding()]
param(
    [string] $SiteRoot = (Join-Path $PSScriptRoot '..'),
    [string] $ContentRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-presentation-policy.json'),
    [string] $GuardPath = (Join-Path $PSScriptRoot 'Test-TechnicalBlogPresentationGuard.ps1')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $GuardPath -PathType Leaf)) {
    throw "blog-presentation-guard-missing: $GuardPath"
}

$global:LASTEXITCODE = 0
& $GuardPath -SiteRoot ([IO.Path]::GetFullPath($SiteRoot)) -PolicyPath ([IO.Path]::GetFullPath($PolicyPath)) -ContentRoot ([IO.Path]::GetFullPath($ContentRoot))
exit $LASTEXITCODE
