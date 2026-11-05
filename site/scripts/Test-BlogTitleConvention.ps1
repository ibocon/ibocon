[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $ManifestPath = (Join-Path $PSScriptRoot 'blog-title-migration.json'),
    [string] $SlugManifestPath = (Join-Path $PSScriptRoot 'blog-slugs.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-Violation {
    param([Collections.Generic.List[string]] $Violations, [string] $Code, [string] $Path)

    $Violations.Add("${Code}: $Path")
}

function Get-PostTitle {
    param([string] $Content, [string] $Path)

    $match = [regex]::Match($Content, '(?m)^title:\s*"(?<title>[^"]+)"\s*$')
    if (-not $match.Success) {
        throw "blog-title-missing: $Path"
    }

    return $match.Groups['title'].Value
}

$resolvedBlogRoot = [IO.Path]::GetFullPath($BlogRoot)
$resolvedManifestPath = [IO.Path]::GetFullPath($ManifestPath)
$resolvedSlugManifestPath = [IO.Path]::GetFullPath($SlugManifestPath)
$violations = [Collections.Generic.List[string]]::new()
$manifest = @(Get-Content -Raw -LiteralPath $resolvedManifestPath | ConvertFrom-Json)
$posts = @(Get-ChildItem -LiteralPath $resolvedBlogRoot -File -Filter '*.md' | Sort-Object Name)
$slugManifest = @(Get-Content -Raw -LiteralPath $resolvedSlugManifestPath | ConvertFrom-Json)
$manifestByFile = @{}

foreach ($entry in $manifest) {
    if ($manifestByFile.ContainsKey($entry.file)) {
        Add-Violation -Violations $violations -Code 'blog-title-manifest-duplicate-file' -Path $entry.file
        continue
    }

    $manifestByFile[$entry.file] = $entry
}

foreach ($post in $posts) {
    if (-not $manifestByFile.ContainsKey($post.Name)) {
        Add-Violation -Violations $violations -Code 'blog-title-manifest-entry-missing' -Path $post.Name
        continue
    }

    $title = Get-PostTitle -Content (Get-Content -Raw -LiteralPath $post.FullName) -Path $post.Name
    $entry = $manifestByFile[$post.Name]
    if ($title -ne $entry.title) {
        Add-Violation -Violations $violations -Code 'blog-title-manifest-title-drift' -Path $post.Name
    }

    if ($title.Length -lt 20 -or $title.Length -gt 60) {
        Add-Violation -Violations $violations -Code 'blog-title-length-invalid' -Path $post.Name
    }

    if ($title -match '^\[') {
        Add-Violation -Violations $violations -Code 'blog-title-prefix-forbidden' -Path $post.Name
    }

    if (@($title.ToCharArray() | Where-Object { $_ -eq ':' }).Count -ne 1) {
        Add-Violation -Violations $violations -Code 'blog-title-context-separator-invalid' -Path $post.Name
    }

    if ($title -match '\s[-+]\s|\s:\s') {
        Add-Violation -Violations $violations -Code 'blog-title-separator-mixed' -Path $post.Name
    }

    if ($title -match '(알아보자|해보자|작성해보자)') {
        Add-Violation -Violations $violations -Code 'blog-title-recommendation-ending-forbidden' -Path $post.Name
    }
}

foreach ($entry in $manifest) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedBlogRoot $entry.file) -PathType Leaf)) {
        Add-Violation -Violations $violations -Code 'blog-title-manifest-file-missing' -Path $entry.file
    }
}

$slugFiles = @($slugManifest | ForEach-Object { "$($_.slug).md" })
if (@($slugFiles | Sort-Object -Unique).Count -ne $slugFiles.Count) {
    Add-Violation -Violations $violations -Code 'blog-title-slug-duplicate' -Path $resolvedSlugManifestPath
}

foreach ($slugFile in $slugFiles) {
    if (-not (Test-Path -LiteralPath (Join-Path $resolvedBlogRoot $slugFile) -PathType Leaf)) {
        Add-Violation -Violations $violations -Code 'blog-title-slug-file-missing' -Path $slugFile
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[blog-title-convention] OK posts=$($posts.Count)"
