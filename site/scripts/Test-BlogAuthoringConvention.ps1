[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-authoring-policy.json')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-Violation {
    param([Collections.Generic.List[string]] $Violations, [string] $Code, [string] $Path)

    $Violations.Add("${Code}: $Path")
}

function Get-PostParts {
    param([string] $Content, [string] $Path)

    $match = [regex]::Match($Content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
    if (-not $match.Success) {
        throw "blog-authoring-frontmatter-missing: $Path"
    }

    return [pscustomobject]@{
        FrontMatter = $match.Groups['frontMatter'].Value
        Body = $match.Groups['body'].Value
    }
}

function Get-FrontMatterValue {
    param([string] $FrontMatter, [string] $Name)

    $match = [regex]::Match($FrontMatter, "(?m)^$([regex]::Escape($Name)):\s*(?<value>.*?)\s*$")
    if (-not $match.Success) {
        return $null
    }

    return $match.Groups['value'].Value.Trim().Trim('"', "'")
}

function Test-Heading {
    param([string] $Body, [string] $Heading)

    return [regex]::IsMatch($Body, "(?m)^##\s+$([regex]::Escape($Heading))\s*$")
}

function Test-RoleHeading {
    param([string] $Body, [object] $Policy, [string] $Role)

    $aliases = @($Policy.sectionAliases.$Role)
    if ($aliases.Count -eq 0) {
        throw "blog-authoring-policy-section-alias-missing: $Role"
    }

    return @($aliases | Where-Object { Test-Heading -Body $Body -Heading ([string] $_) }).Count -gt 0
}

$resolvedBlogRoot = [IO.Path]::GetFullPath($BlogRoot)
$resolvedPolicyPath = [IO.Path]::GetFullPath($PolicyPath)
$policy = Get-Content -Raw -LiteralPath $resolvedPolicyPath | ConvertFrom-Json
$violations = [Collections.Generic.List[string]]::new()
$validatedCount = 0

foreach ($post in Get-ChildItem -LiteralPath $resolvedBlogRoot -File -Filter '*.md' | Sort-Object Name) {
    $parts = Get-PostParts -Content (Get-Content -Raw -LiteralPath $post.FullName) -Path $post.Name
    $version = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'authoringVersion'
    if ($version -ne [string] $policy.authoringVersion) {
        continue
    }

    $validatedCount++
    $audience = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'audience'
    $articleType = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'articleType'
    $description = Get-FrontMatterValue -FrontMatter $parts.FrontMatter -Name 'description'

    if ([string]::IsNullOrWhiteSpace($audience)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-audience-missing' -Path $post.Name
    }

    if ([string]::IsNullOrWhiteSpace($articleType)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-article-type-missing' -Path $post.Name
        continue
    }

    if (-not ($policy.articleTypes.PSObject.Properties.Name -contains $articleType)) {
        Add-Violation -Violations $violations -Code 'blog-authoring-article-type-invalid' -Path $post.Name
        continue
    }

    if ([string]::IsNullOrWhiteSpace($description) -or
        $description.Length -lt [int] $policy.description.minLength -or
        $description.Length -gt [int] $policy.description.maxLength) {
        Add-Violation -Violations $violations -Code 'blog-authoring-description-length-invalid' -Path $post.Name
    }

    $requiredRoles = @($policy.commonSections) + @($policy.articleTypes.$articleType)
    foreach ($role in $requiredRoles) {
        if (-not (Test-RoleHeading -Body $parts.Body -Policy $policy -Role ([string] $role))) {
            Add-Violation -Violations $violations -Code 'blog-authoring-required-section-missing' -Path "$($post.Name)#$role"
        }
    }

    foreach ($image in [regex]::Matches($parts.Body, '!\[(?<alt>[^\]]*)\]\([^\)]*\)')) {
        if ([string]::IsNullOrWhiteSpace($image.Groups['alt'].Value)) {
            Add-Violation -Violations $violations -Code 'blog-authoring-image-alt-missing' -Path $post.Name
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[blog-authoring-convention] OK posts=$validatedCount"
