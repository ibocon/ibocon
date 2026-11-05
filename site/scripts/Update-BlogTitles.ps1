[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $ManifestPath = (Join-Path $PSScriptRoot 'blog-title-migration.json'),
    [switch] $WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-TitleLine {
    param([string] $Content, [string] $Path)

    $match = [regex]::Match($Content, '(?m)^title:\s*"(?<title>[^"]+)"\s*$')
    if (-not $match.Success) {
        throw "blog-title-migration-title-missing: $Path"
    }

    return $match
}

$resolvedBlogRoot = [IO.Path]::GetFullPath($BlogRoot)
$resolvedManifestPath = [IO.Path]::GetFullPath($ManifestPath)
$manifest = @(Get-Content -Raw -LiteralPath $resolvedManifestPath | ConvertFrom-Json)
$files = @(Get-ChildItem -LiteralPath $resolvedBlogRoot -File -Filter '*.md' | Sort-Object Name)

if ($manifest.Count -ne $files.Count) {
    throw "blog-title-migration-coverage-mismatch: manifest=$($manifest.Count) files=$($files.Count)"
}

$manifestFiles = @($manifest.file)
if (@($manifestFiles | Sort-Object -Unique).Count -ne $manifestFiles.Count) {
    throw 'blog-title-migration-duplicate-file'
}

$updates = [Collections.Generic.List[object]]::new()
foreach ($entry in $manifest) {
    $path = Join-Path $resolvedBlogRoot $entry.file
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "blog-title-migration-file-missing: $($entry.file)"
    }

    $content = Get-Content -Raw -LiteralPath $path
    $titleMatch = Get-TitleLine -Content $content -Path $entry.file
    if ($entry.PSObject.Properties.Name -contains 'expectedTitle' -and
        $titleMatch.Groups['title'].Value -ne $entry.expectedTitle) {
        throw "blog-title-migration-source-drift: $($entry.file)"
    }

    $updates.Add([pscustomobject]@{
        File = $entry.file
        Path = $path
        Content = $content
        TitleMatch = $titleMatch
        Title = $entry.title
    })
}

foreach ($update in $updates) {
    $replacement = 'title: "' + $update.Title + '"'
    $updatedContent = $update.Content.Substring(0, $update.TitleMatch.Index) +
        $replacement +
        $update.Content.Substring($update.TitleMatch.Index + $update.TitleMatch.Length)

    if ($WhatIf) {
        Write-Output "blog-title-migration would-update $($update.File)"
        continue
    }

    [IO.File]::WriteAllText($update.Path, $updatedContent, [Text.UTF8Encoding]::new($false))
    Write-Output "blog-title-migration updated $($update.File)"
}

Write-Output "blog-title-migration complete count=$($updates.Count) whatIf=$WhatIf"
