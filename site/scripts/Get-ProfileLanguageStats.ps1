[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $User,
    [Parameter(Mandatory)] [string] $OutputPath,
    [int] $Limit = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-WeightedLanguageShares {
    # Repositories: 각 항목은 Languages(이름 -> 바이트 해시), MyCommits, TotalCommits를 가진다.
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]] $Repositories,
        [int] $Limit = 8
    )

    $weights = @{}
    foreach ($repository in $Repositories) {
        if ($repository.TotalCommits -le 0 -or $repository.MyCommits -le 0) {
            continue
        }

        $ratio = $repository.MyCommits / $repository.TotalCommits
        foreach ($language in $repository.Languages.Keys) {
            $weights[$language] = ($weights[$language] ?? 0) + ($repository.Languages[$language] * $ratio)
        }
    }

    $total = 0.0
    foreach ($weight in $weights.Values) {
        $total += $weight
    }

    if ($total -le 0) {
        return , @()
    }

    $ranked = @($weights.GetEnumerator() | Sort-Object Value -Descending)
    $shares = @()
    $rest = 0.0
    for ($index = 0; $index -lt $ranked.Count; $index++) {
        if ($index -lt $Limit) {
            $shares += [pscustomobject]@{ Name = $ranked[$index].Key; Percent = [math]::Round(100 * $ranked[$index].Value / $total, 1) }
        }
        else {
            $rest += $ranked[$index].Value
        }
    }

    if ($rest -gt 0) {
        $shares += [pscustomobject]@{ Name = 'Other'; Percent = [math]::Round(100 * $rest / $total, 1) }
    }

    return , $shares
}

function ConvertTo-LanguageSvg {
    param(
        [Parameter(Mandatory)] [object[]] $Shares,
        [Parameter(Mandatory)] [string] $Scope
    )

    $rowHeight = 28
    $height = 64 + ($Shares.Count * $rowHeight)
    $rows = for ($index = 0; $index -lt $Shares.Count; $index++) {
        $share = $Shares[$index]
        $top = 56 + ($index * $rowHeight)
        $barWidth = [math]::Max(2, [math]::Round(3.2 * $share.Percent))
        $name = [System.Net.WebUtility]::HtmlEncode($share.Name)
        "<text x=`"16`" y=`"$($top + 14)`" font-size=`"13`" fill=`"#2f81f7`">$name</text>" +
        "<rect x=`"140`" y=`"$($top + 3)`" width=`"$barWidth`" height=`"12`" rx=`"3`" fill=`"#2f81f7`"/>" +
        "<text x=`"$(140 + $barWidth + 8)`" y=`"$($top + 14)`" font-size=`"12`" fill=`"#8b949e`">$($share.Percent)%</text>"
    }

    $scopeText = [System.Net.WebUtility]::HtmlEncode($Scope)
    return @"
<svg xmlns="http://www.w3.org/2000/svg" width="480" height="$height" viewBox="0 0 480 $height" role="img" aria-label="Most used languages">
<rect width="480" height="$height" rx="8" fill="#0d1117"/>
<text x="16" y="28" font-size="16" font-weight="600" fill="#e6edf3">Most Used Languages</text>
<text x="16" y="44" font-size="11" fill="#8b949e">$scopeText</text>
$($rows -join "`n")
</svg>
"@
}

function Get-OwnerRepositories {
    param(
        [Parameter(Mandatory)] [string] $Owner,
        [Parameter(Mandatory)] [string] $Token,
        [Parameter(Mandatory)] [string] $UserNodeId
    )

    $query = 'query($owner:String!,$userId:ID!,$cursor:String){repositoryOwner(login:$owner){repositories(first:50,after:$cursor,isFork:false,ownerAffiliations:OWNER){pageInfo{hasNextPage endCursor}nodes{isArchived languages(first:12,orderBy:{field:SIZE,direction:DESC}){edges{size node{name}}}defaultBranchRef{target{...on Commit{mine:history(author:{id:$userId}){totalCount}total:history{totalCount}}}}}}}}'
    $cursor = $null
    do {
        $env:GH_TOKEN = $Token
        $arguments = @('api', 'graphql', '-f', "query=$query", '-f', "owner=$Owner", '-f', "userId=$UserNodeId")
        if ($cursor) {
            $arguments += @('-f', "cursor=$cursor")
        }

        $response = & gh @arguments | ConvertFrom-Json
        if ($LASTEXITCODE -ne 0 -or $null -eq $response.data.repositoryOwner) {
            throw "Failed to query repositories of '$Owner'."
        }

        $page = $response.data.repositoryOwner.repositories
        foreach ($node in $page.nodes) {
            if ($null -eq $node.defaultBranchRef -or $null -eq $node.defaultBranchRef.target) {
                continue
            }

            $history = $node.defaultBranchRef.target
            if ($null -eq $history.PSObject.Properties['mine']) {
                continue
            }

            $languages = @{}
            foreach ($edge in $node.languages.edges) {
                $languages[$edge.node.name] = [long] $edge.size
            }

            [pscustomobject]@{
                Languages    = $languages
                MyCommits    = $history.mine.totalCount
                TotalCommits = $history.total.totalCount
            }
        }

        $cursor = $page.pageInfo.endCursor
    } while ($page.pageInfo.hasNextPage)
}

if ($MyInvocation.InvocationName -ne '.') {
    $env:GH_TOKEN = $env:TOKEN_IBOCON
    $userNodeId = (& gh api "users/$User" --jq .node_id)
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($userNodeId)) {
        throw "Failed to resolve the node id of user '$User'."
    }

    $repositories = @()
    $repositories += Get-OwnerRepositories -Owner $User -Token $env:TOKEN_IBOCON -UserNodeId $userNodeId
    $repositories += Get-OwnerRepositories -Owner 'BotanicSoft' -Token $env:TOKEN_BOTANICSOFT -UserNodeId $userNodeId

    $shares = Get-WeightedLanguageShares -Repositories $repositories -Limit $Limit
    if ($shares.Count -eq 0) {
        throw 'No language data was collected; refusing to overwrite the published SVG.'
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
    ConvertTo-LanguageSvg -Shares $shares -Scope 'ibocon + BotanicSoft, weighted by my commits' |
        Set-Content -LiteralPath $OutputPath -Encoding UTF8
}
