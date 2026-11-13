#!/usr/bin/env pwsh
#requires -Version 7.0

<#
.SYNOPSIS
    ibocon 블로그(site/, Astro)를 로컬에서 기동한다.

.DESCRIPTION
    1) 사전 점검: site/package.json, npm, 포트 점유 여부를 확인한다.
    2) 사전 준비: node_modules 가 없으면 npm ci(없으면 npm install)로 의존성을 설치한다.
    3) Mode 에 따라 기동한다.
       - Dev     : astro dev (HMR, 초안 미리보기 용도, 기본값)
       - Preview : astro build 후 astro preview (배포 산출물 확인 용도)
    기동 후 -OpenBrowser 가 있으면 서버가 응답할 때까지 기다렸다가 브라우저를 연다.
    서버는 포그라운드로 실행되며 Ctrl+C 로 종료한다.

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File D:\Source\BotanicSoft\ibocon\scripts\Start-BlogSite.ps1

.EXAMPLE
    pwsh -NoProfile -ExecutionPolicy Bypass -File D:\Source\BotanicSoft\ibocon\scripts\Start-BlogSite.ps1 -Mode Preview -OpenBrowser
#>

[CmdletBinding()]
param(
    [ValidateSet('Dev', 'Preview')]
    [string] $Mode = 'Dev',

    [ValidateRange(1, 65535)]
    [int] $Port = 4321,

    [string] $BindHost = '127.0.0.1',

    [switch] $NoInstall,

    [switch] $NoBuild,

    [switch] $OpenBrowser,

    [switch] $StopExisting,

    [switch] $DryRun,

    [Parameter(DontShow)]
    [string] $RepositoryRoot = (Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [Text.UTF8Encoding]::new($false)

$Tag = '[blog-site]'
$SitePath = Join-Path -Path $RepositoryRoot -ChildPath 'site'
$PackagePath = Join-Path -Path $SitePath -ChildPath 'package.json'
$Url = "http://${BindHost}:$Port/"

if (-not (Test-Path -LiteralPath $PackagePath -PathType Leaf)) {
    throw "$Tag site-package-missing: $PackagePath"
}

$Npm = Get-Command -Name 'npm.cmd', 'npm' -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -eq $Npm) {
    throw "$Tag npm-unavailable: Node.js 를 설치하고 PATH 에 npm 이 잡히는지 확인한다."
}

function Invoke-Npm {
    param([Parameter(Mandatory)][string[]] $Arguments)

    Write-Output "$Tag npm $($Arguments -join ' ')"
    if ($DryRun) { return }

    & $Npm.Source @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Tag npm-failed: 'npm $($Arguments -join ' ')' exit code $LASTEXITCODE"
    }
}

# 포트 점검: 점유 중이면 -StopExisting 일 때만 해당 listener 를 종료한다.
$Listener = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1
if ($null -ne $Listener) {
    $Owner = Get-Process -Id $Listener.OwningProcess -ErrorAction SilentlyContinue
    $OwnerName = if ($null -ne $Owner) { $Owner.ProcessName } else { 'unknown' }
    if (-not $StopExisting) {
        throw "$Tag port-in-use: $Port 를 $OwnerName(PID $($Listener.OwningProcess)) 가 사용 중이다. -StopExisting 으로 종료하거나 -Port 를 바꾼다."
    }

    Write-Output "$Tag stopping existing listener: $OwnerName (PID $($Listener.OwningProcess))"
    if (-not $DryRun) {
        Stop-Process -Id $Listener.OwningProcess -Force
        Start-Sleep -Milliseconds 500
    }
}

$NpmPrefix = @('--prefix', $SitePath)

if (-not $NoInstall -and -not (Test-Path -LiteralPath (Join-Path -Path $SitePath -ChildPath 'node_modules') -PathType Container)) {
    $Install = if (Test-Path -LiteralPath (Join-Path -Path $SitePath -ChildPath 'package-lock.json') -PathType Leaf) { 'ci' } else { 'install' }
    Invoke-Npm -Arguments ($NpmPrefix + $Install)
}

if ($Mode -eq 'Preview' -and -not $NoBuild) {
    Invoke-Npm -Arguments ($NpmPrefix + @('run', 'build'))
}

$ServeScript = if ($Mode -eq 'Preview') { 'preview' } else { 'dev' }
$ServeArguments = $NpmPrefix + @('run', $ServeScript, '--', '--host', $BindHost, '--port', $Port)

if ($DryRun) {
    Write-Output "$Tag npm $($ServeArguments -join ' ')"
    Write-Output "$Tag dry-run complete (mode=$Mode, url=$Url)"
    return
}

if ($OpenBrowser) {
    # 서버가 응답할 때까지 백그라운드 잡에서 대기한 뒤 브라우저를 연다.
    $null = Start-ThreadJob -ArgumentList $Url -ScriptBlock {
        param($TargetUrl)
        $Deadline = (Get-Date).AddSeconds(90)
        while ((Get-Date) -lt $Deadline) {
            try {
                $null = Invoke-WebRequest -Uri $TargetUrl -Method Head -TimeoutSec 2 -ErrorAction Stop
                Start-Process $TargetUrl
                return
            }
            catch {
                Start-Sleep -Milliseconds 500
            }
        }
    }
}

Write-Output "$Tag $Mode -> $Url (Ctrl+C 로 종료)"
& $Npm.Source @ServeArguments
exit $LASTEXITCODE
