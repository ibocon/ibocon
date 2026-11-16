#!/usr/bin/env pwsh
#requires -Version 7.0

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $SiteRoot,

    [Parameter(Mandatory)]
    [string] $PolicyPath,

    [string] $ContentRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Add-PresentationViolation {
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [Collections.Generic.List[string]] $Violations,
        [Parameter(Mandatory)] [string] $Code,
        [Parameter(Mandatory)] [string] $Target
    )

    $Violations.Add("technical-blog-presentation-${Code}: $Target")
}

function Get-PolicyValue {
    param([AllowNull()] [object] $Object, [Parameter(Mandatory)] [string] $Name)

    if ($null -eq $Object -or $null -eq $Object.PSObject.Properties[$Name]) {
        return $null
    }

    return $Object.PSObject.Properties[$Name].Value
}

function Get-PresentationStringArray {
    param([AllowNull()] [object] $Value)

    return @($Value | ForEach-Object { [string] $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

function Test-UniqueNonEmptyList {
    param([AllowNull()] [object] $Value)

    $Items = @(Get-PresentationStringArray -Value $Value)
    return $Items.Count -gt 0 -and @($Items | Select-Object -Unique).Count -eq $Items.Count
}

function Test-CoverExtensionPolicy {
    param([Parameter(Mandatory)] [object] $Covers)

    $Token = Get-PolicyValue -Object $Covers -Name 'aspectToken'
    if ($null -ne $Token -and ([string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Token -Name 'name')) -or
            [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Token -Name 'value')))) {
        return $false
    }

    $SurfaceList = Get-PolicyValue -Object $Covers -Name 'surfaces'
    foreach ($Surface in $(if ($null -eq $SurfaceList) { @() } else { @($SurfaceList) })) {
        if ($null -eq $Surface -or [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Surface -Name 'selector')) -or
            -not (Test-UniqueNonEmptyList -Value (Get-PolicyValue -Object $Surface -Name 'requiredCssDeclarations'))) {
            return $false
        }
    }

    $Forbidden = Get-PolicyValue -Object $Covers -Name 'forbiddenCssDeclarations'
    if ($null -ne $Forbidden -and -not (Test-UniqueNonEmptyList -Value $Forbidden)) {
        return $false
    }

    $Raster = Get-PolicyValue -Object $Covers -Name 'raster'
    if ($null -ne $Raster) {
        $Min = Get-PolicyValue -Object $Raster -Name 'minAspect'
        $Max = Get-PolicyValue -Object $Raster -Name 'maxAspect'
        if ($null -eq $Min -or $null -eq $Max -or [double] $Min -le 0 -or [double] $Max -le [double] $Min) {
            return $false
        }
    }

    return $true
}

function Test-PresentationPolicy {
    param([Parameter(Mandatory)] [object] $Policy, [switch] $RequireDiagramOptIn)

    $Violations = [Collections.Generic.List[string]]::new()
    if ([int] (Get-PolicyValue -Object $Policy -Name 'schemaVersion') -ne 1) {
        $Violations.Add('technical-blog-presentation-policy-schema-version-invalid')
    }

    $Stylesheet = Get-PolicyValue -Object $Policy -Name 'stylesheet'
    if ($null -eq $Stylesheet -or [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Stylesheet -Name 'path')) -or
        -not (Test-UniqueNonEmptyList -Value (Get-PolicyValue -Object $Stylesheet -Name 'requiredTokens')) -or
        -not (Test-UniqueNonEmptyList -Value (Get-PolicyValue -Object $Stylesheet -Name 'requiredRules'))) {
        $Violations.Add('technical-blog-presentation-policy-stylesheet-invalid')
    }

    $Diagrams = Get-PolicyValue -Object $Policy -Name 'diagrams'
    foreach ($Name in @('maxNodes', 'maxLabelLineLength', 'maxHorizontalChain')) {
        $Limit = Get-PolicyValue -Object $Diagrams -Name $Name
        if ($null -eq $Limit -or [int] $Limit -lt 1) {
            $Violations.Add('technical-blog-presentation-policy-diagram-limits-invalid')
            break
        }
    }

    if ($RequireDiagramOptIn) {
        $OptIn = Get-PolicyValue -Object $Diagrams -Name 'optIn'
        if ($null -eq $OptIn -or [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $OptIn -Name 'frontMatterKey')) -or
            $null -eq $OptIn.PSObject.Properties['value']) {
            $Violations.Add('technical-blog-presentation-policy-diagram-opt-in-invalid')
        }
    }

    $Covers = Get-PolicyValue -Object $Policy -Name 'covers'
    $Margin = Get-PolicyValue -Object $Covers -Name 'minSafeMarginPercent'
    $CoverInvalid = $null -eq $Covers -or
        [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Covers -Name 'directory')) -or
        [string] (Get-PolicyValue -Object $Covers -Name 'viewBox') -notmatch '^0 0 \d+(\.\d+)? \d+(\.\d+)?$' -or
        $null -eq $Margin -or [double] $Margin -le 0 -or [double] $Margin -ge 50 -or
        [string]::IsNullOrWhiteSpace([string] (Get-PolicyValue -Object $Covers -Name 'cssSelector')) -or
        -not (Test-UniqueNonEmptyList -Value (Get-PolicyValue -Object $Covers -Name 'requiredCssDeclarations'))
    if (-not $CoverInvalid) {
        $CoverInvalid = -not (Test-CoverExtensionPolicy -Covers $Covers)
    }

    if ($CoverInvalid) {
        $Violations.Add('technical-blog-presentation-policy-cover-invalid')
    }

    return @($Violations | Sort-Object -Unique)
}

function Get-MermaidDiagramMetrics {
    param([Parameter(Mandatory)] [string] $Source)

    $Direction = 'TB'
    $Header = [regex]::Match($Source, '(?m)^\s*(?:flowchart|graph)\s*(?<dir>TB|TD|BT|LR|RL)?')
    if (-not $Header.Success) {
        return $null
    }

    if ($Header.Groups['dir'].Success) { $Direction = $Header.Groups['dir'].Value }

    $LabelLines = [Collections.Generic.List[string]]::new()
    $Nodes = [Collections.Generic.HashSet[string]]::new()
    $Next = @{}
    foreach ($RawLine in ($Source -split '\r?\n')) {
        $Line = $RawLine.Trim()
        if ($Line -eq '' -or $Line -match '^(?:flowchart|graph|style|classDef|class|linkStyle|subgraph|end|direction|%%)(\s|$)') {
            continue
        }

        foreach ($Label in [regex]::Matches($Line, '\[\s*"?(?<text>[^\]"]*)"?\s*\]|\(\s*"?(?<text>[^\)"]*)"?\s*\)|\|(?<text>[^|]*)\|')) {
            foreach ($Part in ($Label.Groups['text'].Value -split '<br\s*/?>')) {
                $LabelLines.Add($Part.Trim())
            }
        }

        $Bare = [regex]::Replace($Line, '\[[^\]]*\]|\([^\)]*\)|\|[^|]*\|', '')
        $Ids = @([regex]::Split($Bare, '\s*(?:-->|-\.->|==>|---|-\.-|&)\s*') | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^[A-Za-z_]\w*$' })
        foreach ($Id in $Ids) { [void] $Nodes.Add($Id) }
        for ($Index = 0; $Index -lt $Ids.Count - 1; $Index++) {
            if (-not $Next.ContainsKey($Ids[$Index])) { $Next[$Ids[$Index]] = [Collections.Generic.List[string]]::new() }
            $Next[$Ids[$Index]].Add($Ids[$Index + 1])
        }
    }

    $Memo = @{}
    $Walk = $null
    $Walk = {
        param([string] $Id, [Collections.Generic.HashSet[string]] $Path)

        if ($Memo.ContainsKey($Id)) { return $Memo[$Id] }
        if (-not $Path.Add($Id)) { return 1 }
        $Best = 1
        if ($Next.ContainsKey($Id)) {
            foreach ($Target in $Next[$Id]) {
                $Best = [Math]::Max($Best, 1 + (& $Walk $Target $Path))
            }
        }

        [void] $Path.Remove($Id)
        $Memo[$Id] = $Best
        return $Best
    }

    $Chain = 0
    foreach ($Id in $Nodes) {
        $Chain = [Math]::Max($Chain, (& $Walk $Id ([Collections.Generic.HashSet[string]]::new())))
    }

    $LongestLine = 0
    foreach ($Text in $LabelLines) { $LongestLine = [Math]::Max($LongestLine, $Text.Length) }
    return [pscustomobject]@{ Direction = $Direction; NodeCount = $Nodes.Count; LongestLabelLine = $LongestLine; ChainLength = $Chain }
}

function Get-CoverMeasurement {
    param([Parameter(Mandatory)] [xml] $Svg)

    $Root = $Svg.DocumentElement
    $ViewBox = @(([string] $Root.GetAttribute('viewBox')) -split '\s+')
    $Scale = 1.0; $OffsetX = 0.0; $OffsetY = 0.0
    foreach ($Element in @($Svg.SelectNodes('//*[@transform]'))) {
        $Transform = [string] $Element.GetAttribute('transform')
        $IsTopGroup = $Element.LocalName -eq 'g' -and $Element.ParentNode -eq $Root
        $Match = [regex]::Match($Transform, '^translate\(\s*(?<x>-?[\d.]+)[\s,]+(?<y>-?[\d.]+)\s*\)\s*scale\(\s*(?<s>[\d.]+)\s*\)$')
        if (-not $IsTopGroup -or -not $Match.Success) {
            return [pscustomobject]@{ Supported = $false; ViewBox = $ViewBox; Margin = 0.0 }
        }

        $OffsetX = [double] $Match.Groups['x'].Value; $OffsetY = [double] $Match.Groups['y'].Value; $Scale = [double] $Match.Groups['s'].Value
    }

    $Width = [double] $ViewBox[2]; $Height = [double] $ViewBox[3]
    $Bounds = [Collections.Generic.List[double[]]]::new()
    foreach ($Rect in @($Svg.SelectNodes('//*[local-name()="rect"]'))) {
        $RectWidth = [double] $Rect.GetAttribute('width'); $RectHeight = [double] $Rect.GetAttribute('height')
        if ($RectWidth -ge $Width -and $RectHeight -ge $Height) { continue }
        $X = [double] $Rect.GetAttribute('x'); $Y = [double] $Rect.GetAttribute('y')
        $Bounds.Add([double[]] @($X, $Y, ($X + $RectWidth), ($Y + $RectHeight)))
    }

    foreach ($Circle in @($Svg.SelectNodes('//*[local-name()="circle"]'))) {
        $Cx = [double] $Circle.GetAttribute('cx'); $Cy = [double] $Circle.GetAttribute('cy'); $Radius = [double] $Circle.GetAttribute('r')
        $Bounds.Add([double[]] @(($Cx - $Radius), ($Cy - $Radius), ($Cx + $Radius), ($Cy + $Radius)))
    }

    if ($Bounds.Count -eq 0) {
        return [pscustomobject]@{ Supported = $false; ViewBox = $ViewBox; Margin = 0.0 }
    }

    $MinX = ($Bounds | ForEach-Object { $_[0] } | Measure-Object -Minimum).Minimum * $Scale + $OffsetX
    $MinY = ($Bounds | ForEach-Object { $_[1] } | Measure-Object -Minimum).Minimum * $Scale + $OffsetY
    $MaxX = ($Bounds | ForEach-Object { $_[2] } | Measure-Object -Maximum).Maximum * $Scale + $OffsetX
    $MaxY = ($Bounds | ForEach-Object { $_[3] } | Measure-Object -Maximum).Maximum * $Scale + $OffsetY
    $Margins = @(($MinX / $Width), (($Width - $MaxX) / $Width), ($MinY / $Height), (($Height - $MaxY) / $Height))
    return [pscustomobject]@{ Supported = $true; ViewBox = $ViewBox; Margin = ($Margins | Measure-Object -Minimum).Minimum * 100 }
}

function Get-CssRuleBodies {
    param([Parameter(Mandatory)] [string] $Styles, [Parameter(Mandatory)] [string] $Selector)

    $Bodies = [Collections.Generic.List[string]]::new()
    foreach ($Rule in [regex]::Matches($Styles, '(?<selector>[^{}]+)\{(?<body>[^{}]*)\}')) {
        $Selectors = @($Rule.Groups['selector'].Value -split ',' | ForEach-Object { $_.Trim() })
        if ($Selectors -contains $Selector) {
            $Bodies.Add($Rule.Groups['body'].Value)
        }
    }

    return @($Bodies)
}

function Get-FrontMatterValue {
    param([Parameter(Mandatory)] [string] $FrontMatter, [Parameter(Mandatory)] [string] $Name)

    $Match = [regex]::Match($FrontMatter, "(?m)^$([regex]::Escape($Name)):\s*(?<value>.*?)\s*$")
    if (-not $Match.Success) {
        return $null
    }

    return $Match.Groups['value'].Value.Trim().Trim('"', "'")
}

function Get-ImageAspect {
    param([Parameter(Mandatory)] [string] $Path)

    if ([IO.Path]::GetExtension($Path).ToLowerInvariant() -eq '.svg') {
        $ViewBox = [regex]::Match((Get-Content -LiteralPath $Path -Raw -Encoding utf8), 'viewBox\s*=\s*"\s*[-\d.]+[\s,]+[-\d.]+[\s,]+(?<w>[\d.]+)[\s,]+(?<h>[\d.]+)\s*"')
        if (-not $ViewBox.Success -or [double] $ViewBox.Groups['h'].Value -le 0) { return $null }
        return [double] $ViewBox.Groups['w'].Value / [double] $ViewBox.Groups['h'].Value
    }

    $Bytes = [IO.File]::ReadAllBytes($Path)
    $Width = 0; $Height = 0
    if ($Bytes.Length -ge 24 -and $Bytes[0] -eq 0x89 -and $Bytes[1] -eq 0x50) {
        $Width = ([int] $Bytes[16] -shl 24) + ([int] $Bytes[17] -shl 16) + ([int] $Bytes[18] -shl 8) + $Bytes[19]
        $Height = ([int] $Bytes[20] -shl 24) + ([int] $Bytes[21] -shl 16) + ([int] $Bytes[22] -shl 8) + $Bytes[23]
    }
    elseif ($Bytes.Length -ge 10 -and $Bytes[0] -eq 0x47 -and $Bytes[1] -eq 0x49 -and $Bytes[2] -eq 0x46) {
        $Width = $Bytes[6] + ([int] $Bytes[7] -shl 8)
        $Height = $Bytes[8] + ([int] $Bytes[9] -shl 8)
    }
    elseif ($Bytes.Length -ge 4 -and $Bytes[0] -eq 0xFF -and $Bytes[1] -eq 0xD8) {
        $Index = 2
        while ($Index + 9 -lt $Bytes.Length) {
            if ($Bytes[$Index] -ne 0xFF) { $Index++; continue }
            $Marker = $Bytes[$Index + 1]
            if ($Marker -eq 0xFF) { $Index++; continue }
            if ($Marker -eq 0xD8 -or $Marker -eq 0x01 -or ($Marker -ge 0xD0 -and $Marker -le 0xD7)) { $Index += 2; continue }
            $Length = ([int] $Bytes[$Index + 2] -shl 8) + $Bytes[$Index + 3]
            if ($Marker -ge 0xC0 -and $Marker -le 0xCF -and $Marker -ne 0xC4 -and $Marker -ne 0xC8 -and $Marker -ne 0xCC) {
                $Height = ([int] $Bytes[$Index + 5] -shl 8) + $Bytes[$Index + 6]
                $Width = ([int] $Bytes[$Index + 7] -shl 8) + $Bytes[$Index + 8]
                break
            }

            $Index += 2 + $Length
        }
    }
    elseif ($Bytes.Length -ge 30 -and [Text.Encoding]::ASCII.GetString($Bytes, 0, 4) -eq 'RIFF' -and [Text.Encoding]::ASCII.GetString($Bytes, 8, 4) -eq 'WEBP') {
        $Kind = [Text.Encoding]::ASCII.GetString($Bytes, 12, 4)
        if ($Kind -eq 'VP8 ') {
            $Width = ($Bytes[26] + ([int] $Bytes[27] -shl 8)) -band 0x3FFF
            $Height = ($Bytes[28] + ([int] $Bytes[29] -shl 8)) -band 0x3FFF
        }
        elseif ($Kind -eq 'VP8L') {
            $Bits = [long] $Bytes[21] + ([long] $Bytes[22] -shl 8) + ([long] $Bytes[23] -shl 16) + ([long] $Bytes[24] -shl 24)
            $Width = ($Bits -band 0x3FFF) + 1
            $Height = (($Bits -shr 14) -band 0x3FFF) + 1
        }
        elseif ($Kind -eq 'VP8X') {
            $Width = ($Bytes[24] + ([int] $Bytes[25] -shl 8) + ([int] $Bytes[26] -shl 16)) + 1
            $Height = ($Bytes[27] + ([int] $Bytes[28] -shl 8) + ([int] $Bytes[29] -shl 16)) + 1
        }
    }

    if ($Width -le 0 -or $Height -le 0) { return $null }
    return [double] $Width / [double] $Height
}

function Get-PostCoverSource {
    param([Parameter(Mandatory)] [string] $FrontMatter, [Parameter(Mandatory)] [string] $Body)

    $Explicit = Get-FrontMatterValue -FrontMatter $FrontMatter -Name 'coverImage'
    if (-not [string]::IsNullOrWhiteSpace($Explicit)) { return $Explicit }

    $Prose = [regex]::Replace($Body, '(?ms)^```.*?^```', '')
    $Match = [regex]::Match($Prose, '!\[[^\]]*\]\((?<url>/[^\s)]+)(?:\s+[''"][^)]*[''"])?\)')
    if ($Match.Success) { return $Match.Groups['url'].Value }

    return $null
}

$ResolvedSiteRoot = (Resolve-Path -LiteralPath $SiteRoot).Path
$ResolvedPolicyPath = (Resolve-Path -LiteralPath $PolicyPath).Path
$Policy = Get-Content -LiteralPath $ResolvedPolicyPath -Raw -Encoding utf8 | ConvertFrom-Json
$PolicyViolations = @(Test-PresentationPolicy -Policy $Policy -RequireDiagramOptIn:$PSBoundParameters.ContainsKey('ContentRoot'))
if ($PolicyViolations.Count -gt 0) {
    foreach ($Violation in $PolicyViolations) {
        Write-Output "::error::${Violation}: $ResolvedPolicyPath"
    }

    exit 1
}

$Violations = [Collections.Generic.List[string]]::new()
$StylesheetRelative = [string] $Policy.stylesheet.path
$StylePath = Join-Path -Path $ResolvedSiteRoot -ChildPath $StylesheetRelative
$Styles = if (Test-Path -LiteralPath $StylePath -PathType Leaf) { Get-Content -LiteralPath $StylePath -Raw -Encoding utf8 } else { '' }
foreach ($Token in @(Get-PresentationStringArray -Value $Policy.stylesheet.requiredTokens)) {
    if (-not $Styles.Contains("${Token}:")) {
        Add-PresentationViolation -Violations $Violations -Code 'token-missing' -Target "$StylesheetRelative#$Token"
    }
}

foreach ($Rule in @(Get-PresentationStringArray -Value $Policy.stylesheet.requiredRules)) {
    if (-not $Styles.Contains($Rule)) {
        Add-PresentationViolation -Violations $Violations -Code 'rule-missing' -Target "$StylesheetRelative#$Rule"
    }
}

$CoverBodies = @(Get-CssRuleBodies -Styles $Styles -Selector ([string] $Policy.covers.cssSelector))
foreach ($Declaration in @(Get-PresentationStringArray -Value $Policy.covers.requiredCssDeclarations)) {
    if (-not (@($CoverBodies | Where-Object { $_.Contains($Declaration) }).Count -gt 0)) {
        Add-PresentationViolation -Violations $Violations -Code 'cover-css-declaration-missing' -Target "$StylesheetRelative#$Declaration"
    }
}

$AspectToken = Get-PolicyValue -Object $Policy.covers -Name 'aspectToken'
if ($null -ne $AspectToken) {
    $TokenPattern = '(?m)' + [regex]::Escape([string] $AspectToken.name) + '\s*:\s*' + [regex]::Escape([string] $AspectToken.value) + '\s*;'
    if ($Styles -notmatch $TokenPattern) {
        Add-PresentationViolation -Violations $Violations -Code 'cover-aspect-token-drift' -Target "$StylesheetRelative#$($AspectToken.name)"
    }
}

$ConfiguredSurfaces = Get-PolicyValue -Object $Policy.covers -Name 'surfaces'
foreach ($Surface in $(if ($null -eq $ConfiguredSurfaces) { @() } else { @($ConfiguredSurfaces) })) {
    $SurfaceBodies = @(Get-CssRuleBodies -Styles $Styles -Selector ([string] $Surface.selector))
    if ($SurfaceBodies.Count -eq 0) {
        Add-PresentationViolation -Violations $Violations -Code 'cover-surface-missing' -Target "$StylesheetRelative#$($Surface.selector)"
        continue
    }

    foreach ($Declaration in @(Get-PresentationStringArray -Value $Surface.requiredCssDeclarations)) {
        if (-not (@($SurfaceBodies | Where-Object { $_.Contains($Declaration) }).Count -gt 0)) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-css-declaration-missing' -Target "$StylesheetRelative#$($Surface.selector)#$Declaration"
        }
    }
}

if ($null -ne $AspectToken) {
    $TokenUse = 'var(' + [string] $AspectToken.name + ')'
    foreach ($CssRule in [regex]::Matches($Styles, '(?<selector>[^{}]+)\{(?<body>[^{}]*)\}')) {
        $RuleSelector = $CssRule.Groups['selector'].Value.Trim()
        $AspectDeclaration = [regex]::Match($CssRule.Groups['body'].Value, 'aspect-ratio:\s*(?<value>[^;]+)')
        if ($RuleSelector -match 'cover' -and $AspectDeclaration.Success -and $AspectDeclaration.Groups['value'].Value.Trim() -ne $TokenUse) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-aspect-token-drift' -Target "$StylesheetRelative#$RuleSelector"
        }
    }
}

$ForbiddenDeclarations = @(Get-PresentationStringArray -Value (Get-PolicyValue -Object $Policy.covers -Name 'forbiddenCssDeclarations'))
if ($ForbiddenDeclarations.Count -gt 0) {
    foreach ($CssRule in [regex]::Matches($Styles, '(?<selector>[^{}]+)\{(?<body>[^{}]*)\}')) {
        $RuleSelector = $CssRule.Groups['selector'].Value.Trim()
        if ($RuleSelector -notmatch 'cover') { continue }
        foreach ($Declaration in $ForbiddenDeclarations) {
            if ($CssRule.Groups['body'].Value.Contains($Declaration)) {
                Add-PresentationViolation -Violations $Violations -Code 'cover-surface-crop' -Target "$StylesheetRelative#$RuleSelector"
            }
        }
    }
}

$CoverCount = 0
$CoverDirectory = Join-Path -Path $ResolvedSiteRoot -ChildPath ([string] $Policy.covers.directory)
if (Test-Path -LiteralPath $CoverDirectory -PathType Container) {
    foreach ($Cover in @(Get-ChildItem -LiteralPath $CoverDirectory -File -Filter '*.svg' | Sort-Object Name)) {
        $CoverCount++
        $Measurement = Get-CoverMeasurement -Svg ([xml] (Get-Content -LiteralPath $Cover.FullName -Raw -Encoding utf8))
        if (($Measurement.ViewBox -join ' ') -ne [string] $Policy.covers.viewBox) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-viewbox-mismatch' -Target $Cover.Name
        }

        if (-not $Measurement.Supported) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-unsupported-structure' -Target $Cover.Name
        }
        elseif ($Measurement.Margin -lt [double] $Policy.covers.minSafeMarginPercent) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-margin-insufficient' -Target $Cover.Name
        }
    }
}

$PostCount = 0
if ($PSBoundParameters.ContainsKey('ContentRoot')) {
    $ResolvedContentRoot = (Resolve-Path -LiteralPath $ContentRoot).Path
    $OptIn = $Policy.diagrams.optIn
    foreach ($Document in @(Get-ChildItem -LiteralPath $ResolvedContentRoot -File -Filter '*.md' | Sort-Object Name)) {
        $Content = Get-Content -LiteralPath $Document.FullName -Raw -Encoding utf8
        $Parts = [regex]::Match($Content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
        if (-not $Parts.Success) {
            continue
        }

        $Value = Get-FrontMatterValue -FrontMatter $Parts.Groups['frontMatter'].Value -Name ([string] $OptIn.frontMatterKey)
        if ($Value -ne [string] $OptIn.value) {
            continue
        }

        $PostCount++
        $DiagramNumber = 0
        foreach ($Block in [regex]::Matches($Parts.Groups['body'].Value, '(?ms)^```mermaid\s*\r?\n(?<source>.*?)^```')) {
            $DiagramNumber++
            $Metrics = Get-MermaidDiagramMetrics -Source $Block.Groups['source'].Value
            if ($null -eq $Metrics) {
                continue
            }

            $Target = "$($Document.Name)#diagram-$DiagramNumber"
            if ($Metrics.NodeCount -gt [int] $Policy.diagrams.maxNodes) {
                Add-PresentationViolation -Violations $Violations -Code 'diagram-too-many-nodes' -Target $Target
            }

            if ($Metrics.LongestLabelLine -gt [int] $Policy.diagrams.maxLabelLineLength) {
                Add-PresentationViolation -Violations $Violations -Code 'diagram-label-too-long' -Target $Target
            }

            if ($Metrics.Direction -in @('LR', 'RL') -and $Metrics.ChainLength -gt [int] $Policy.diagrams.maxHorizontalChain) {
                Add-PresentationViolation -Violations $Violations -Code 'diagram-horizontal-chain-too-long' -Target $Target
            }
        }
    }
}

$CoverSourceCount = 0
$Raster = Get-PolicyValue -Object $Policy.covers -Name 'raster'
if ($null -ne $Raster -and $PSBoundParameters.ContainsKey('ContentRoot')) {
    $Baseline = @()
    $BaselinePath = [string] (Get-PolicyValue -Object $Raster -Name 'baseline')
    if (-not [string]::IsNullOrWhiteSpace($BaselinePath)) {
        $ResolvedBaseline = Join-Path -Path $ResolvedSiteRoot -ChildPath $BaselinePath
        if (Test-Path -LiteralPath $ResolvedBaseline -PathType Leaf) {
            $Baseline = @((Get-Content -LiteralPath $ResolvedBaseline -Raw -Encoding utf8 | ConvertFrom-Json).allow | ForEach-Object { [string] $_ })
        }
    }

    $Found = [Collections.Generic.HashSet[string]]::new()
    $PublicRoot = Join-Path -Path $ResolvedSiteRoot -ChildPath 'public'
    foreach ($Document in @(Get-ChildItem -LiteralPath $ResolvedContentRoot -File -Filter '*.md' | Sort-Object Name)) {
        $Content = Get-Content -LiteralPath $Document.FullName -Raw -Encoding utf8
        $Parts = [regex]::Match($Content, '\A---\r?\n(?<frontMatter>[\s\S]*?)\r?\n---\r?\n?(?<body>[\s\S]*)\z')
        if (-not $Parts.Success) { continue }

        $Source = Get-PostCoverSource -FrontMatter $Parts.Groups['frontMatter'].Value -Body $Parts.Groups['body'].Value
        if ($null -eq $Source) { continue }

        $CoverSourceCount++
        $SourcePath = Join-Path -Path $PublicRoot -ChildPath $Source.TrimStart('/')
        $Aspect = $null
        if (Test-Path -LiteralPath $SourcePath -PathType Leaf) {
            $Aspect = Get-ImageAspect -Path $SourcePath
        }

        $Code = $null
        if ($null -eq $Aspect) { $Code = 'cover-source-unreadable' }
        elseif ($Aspect -lt [double] $Raster.minAspect -or $Aspect -gt [double] $Raster.maxAspect) { $Code = 'cover-source-aspect-mismatch' }
        if ($null -eq $Code) { continue }

        $Key = "${Code}: $($Document.Name)"
        [void] $Found.Add($Key)
        if ($Baseline -notcontains $Key) {
            Add-PresentationViolation -Violations $Violations -Code $Code -Target $Document.Name
        }
    }

    foreach ($Entry in $Baseline) {
        if (-not $Found.Contains($Entry)) {
            Add-PresentationViolation -Violations $Violations -Code 'cover-baseline-stale' -Target $Entry
        }
    }
}

if ($Violations.Count -gt 0) {
    $Violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

Write-Output "[technical-blog-presentation-guard] OK posts=$PostCount covers=$CoverCount coverSources=$CoverSourceCount"
