#!/usr/bin/env pwsh
#requires -Version 7.0

<#
.SYNOPSIS
    이력서 Local SoT 마크다운(resume/*.md) 내 모든 <table> 블록의 열 너비(<colgroup>) 및 속성을 검증한다.

.DESCRIPTION
    1. 모든 <table> 태그에 fit-page-width="true" 속성이 포함되어 있는지 검증한다.
    2. 모든 <table> 태그 내부에 <colgroup> 블록이 존재하는지 검증한다.
    3. <col width="N"> 태그들의 합계가 ExpectedTotalWidth(기본값 700px)와 일치하는지 검증한다.
    4. 각 <tr> 내부의 <td> 셀 개수가 <col> 개수와 정확히 일치하는지 검증한다.

.PARAMETER Path
    검증 대상 마크다운 디렉터리 또는 파일 경로.

.PARAMETER ExpectedTotalWidth
    테이블 전체 열 너비 합계 기준값 (기본값: 700).

.EXAMPLE
    pwsh -NoProfile -File scripts/Test-NotionTableColumnWidthGuard.ps1 -Path resume
#>

[CmdletBinding()]
param(
    [string] $Path = (Join-Path -Path $PSScriptRoot -ChildPath '../resume'),
    [int] $ExpectedTotalWidth = 700
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ResolvedTarget = (Resolve-Path -LiteralPath $Path).Path
if (Test-Path -LiteralPath $ResolvedTarget -PathType Leaf) {
    $MarkdownFiles = @(Get-Item -LiteralPath $ResolvedTarget)
}
else {
    $MarkdownFiles = @(Get-ChildItem -LiteralPath $ResolvedTarget -Filter '*.md' -File)
}

$Violations = [System.Collections.Generic.List[string]]::new()
$InspectedTables = 0

foreach ($File in $MarkdownFiles) {
    $Content = Get-Content -LiteralPath $File.FullName -Raw
    $TableMatches = [regex]::Matches($Content, '(?s)<table(?<Attrs>[^>]*)>(?<Body>.*?)</table>')

    $TableIndex = 0
    foreach ($Match in $TableMatches) {
        $TableIndex++
        $InspectedTables++
        $Attrs = $Match.Groups['Attrs'].Value
        $Body = $Match.Groups['Body'].Value

        if ($Attrs -notmatch 'fit-page-width="true"') {
            [void] $Violations.Add("$($File.Name) [Table #$TableIndex]: Missing fit-page-width=`"true`" attribute.")
        }

        $ColGroupMatch = [regex]::Match($Body, '(?s)<colgroup>(?<Cols>.*?)</colgroup>')
        if (-not $ColGroupMatch.Success) {
            [void] $Violations.Add("$($File.Name) [Table #$TableIndex]: Missing <colgroup> definition.")
            continue
        }

        $ColMatches = [regex]::Matches($ColGroupMatch.Groups['Cols'].Value, '<col\s+width="(?<Width>\d+)"\s*/?>')
        if ($ColMatches.Count -eq 0) {
            [void] $Violations.Add("$($File.Name) [Table #$TableIndex]: No <col width=`"N`"> tags found inside <colgroup>.")
            continue
        }

        $TotalWidth = 0
        foreach ($Col in $ColMatches) {
            $TotalWidth += [int] $Col.Groups['Width'].Value
        }

        if ($TotalWidth -ne $ExpectedTotalWidth) {
            [void] $Violations.Add("$($File.Name) [Table #$TableIndex]: <col> width sum is $TotalWidth (expected $ExpectedTotalWidth).")
        }

        $RowMatches = [regex]::Matches($Body, '(?s)<tr[^>]*>(?<Cells>.*?)</tr>')
        $RowIndex = 0
        foreach ($Row in $RowMatches) {
            $RowIndex++
            $CellCount = [regex]::Matches($Row.Groups['Cells'].Value, '(?s)<td[^>]*>.*?</td>').Count
            if ($CellCount -ne $ColMatches.Count) {
                [void] $Violations.Add("$($File.Name) [Table #$TableIndex, Row #$RowIndex]: Cell count ($CellCount) does not match <col> count ($($ColMatches.Count)).")
            }
        }
    }
}

if ($Violations.Count -gt 0) {
    foreach ($V in $Violations) {
        Write-Error $V
    }
    exit 1
}

Write-Output "[notion-table-width-guard] OK ($InspectedTables table(s) across $($MarkdownFiles.Count) file(s) verified, total width = ${ExpectedTotalWidth}px)"
exit 0
