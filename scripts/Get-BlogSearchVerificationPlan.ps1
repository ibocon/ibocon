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
if ([IO.Path]::GetFullPath($RepositoryRoot) -ne $expectedRoot) { throw 'blog-search-repository-mismatch' }
$method = switch ($TaskName) {
    '261020_verify_blog-post-search-V1' { 'SearchInputAndClear' }
    '261020_verify_blog-post-search-V2' { 'CategoryAndEmptyState' }
    '261020_verify_blog-tag-filtering-V1' { 'TagOnlyFiltering' }
    '261020_verify_blog-tag-filtering-V2' { 'CategoryTagIntersection' }
    '261020_verify_blog-tag-filtering-V3' { 'CategoryTagEmptyState' }
    '261026_verify_blog-hidden-card-filtering-V1' { 'SearchInputAndClear' }
    '261026_verify_blog-hidden-card-filtering-V2' { 'CategoryAndEmptyState' }
    '261030_verify_blog-search-discovery-ux-V1' { 'SearchRelevanceAndClear' }
    '261030_verify_blog-search-discovery-ux-V2' { 'TagDisclosureAndAppliedFilter' }
    '261030_verify_blog-flat-tags-V1' { 'FlatTagFiltering' }
    '261030_verify_blog-flat-tags-V2' { 'FlatTagSearchFiltering' }
    '261030_verify_blog-flat-tags-V3' { 'FlatTagRssCategories' }
    default { throw 'blog-search-or-tag-scenario-required' }
}
$filter = "(FullyQualifiedName~BlogSearchTests.$method)&(Cost!=Expensive)"
$project = 'tests/Blog.PlaywrightTests/Blog.PlaywrightTests.csproj'
$isTagScenario = $TaskName -like '261020_verify_blog-tag-filtering-*'
$isHiddenCardScenario = $TaskName -like '261026_verify_blog-hidden-card-filtering-*'
$isDiscoveryScenario = $TaskName -like '261030_verify_blog-search-discovery-ux-*'
$isFlatTagScenario = $TaskName -like '261030_verify_blog-flat-tags-*'
$scenario = $TaskName.Split('-')[-1]
$artifactScope = if ($isTagScenario) { 'blog-tag-filtering' } elseif ($isHiddenCardScenario) { 'blog-hidden-card-filtering' } elseif ($isDiscoveryScenario) { 'blog-search-discovery-ux' } elseif ($isFlatTagScenario) { 'blog-flat-tags' } else { 'blog-search' }
$arguments = @('test', $project, '--filter', $filter, '--logger', 'trx', '--results-directory', ".artifacts/$artifactScope/$scenario")
$display = "dotnet test $project --filter `"$filter`" --logger trx --results-directory .artifacts/$artifactScope/$scenario"
[pscustomobject]@{
    Scope = if ($isTagScenario) { 'blog-tag-filtering-playwright' } elseif ($isHiddenCardScenario) { 'blog-hidden-card-filtering-playwright' } else { 'blog-search-playwright' }
    Commands = @($display)
    Invocations = @([pscustomobject]@{ FilePath = 'dotnet'; ArgumentList = $arguments; DisplayCommand = $display })
    Notes = @('Explicit per-scenario selector; Edge-Debug localhost:9222; only created page is closed.')
}
