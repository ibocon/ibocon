#!/usr/bin/env pwsh
#requires -Version 7.0

[CmdletBinding()]
param(
    [string] $ResumePath = (Join-Path $PSScriptRoot '../resume/resume-yegun-kim.md'),
    [string] $OutputPath = (Join-Path $PSScriptRoot '../.artifacts/resume/notion-payload.md')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$content = Get-Content -LiteralPath $ResumePath -Raw
$outputDirectory = Split-Path -Path $OutputPath -Parent
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
[IO.File]::WriteAllText($OutputPath, $content, [Text.UTF8Encoding]::new($false))

[pscustomobject]@{
    SourcePath = (Resolve-Path -LiteralPath $ResumePath).Path
    PayloadPath = (Resolve-Path -LiteralPath $OutputPath).Path
    Sha256 = (Get-FileHash -LiteralPath $OutputPath -Algorithm SHA256).Hash
    TargetPageId = '3dd475218675811299b0e3d6b2baa43d'
} | ConvertTo-Json -Depth 3
