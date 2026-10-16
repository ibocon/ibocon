#requires -Version 7
[CmdletBinding()]
param(
    [string] $Repository = 'ibocon/ibocon',
    [string] $CloudflareAccountId,
    [string] $AdSenseClientId,
    [string] $GaMeasurementId,
    [switch] $PromptCloudflareToken
)

$ErrorActionPreference = 'Stop'

if (-not [string]::IsNullOrWhiteSpace($CloudflareAccountId)) {
    $CloudflareAccountId | & gh secret set CLOUDFLARE_ACCOUNT_ID --repo $Repository
    Write-Information "Registered secret: CLOUDFLARE_ACCOUNT_ID" -InformationAction Continue
}

if ($PromptCloudflareToken) {
    $SecureToken = Read-Host -Prompt 'Enter CLOUDFLARE_CI_WORKERS_TOKEN (console token: ibocon-cloudflare-workers-ci)' -AsSecureString
    $PlainToken = [System.Net.NetworkCredential]::new('', $SecureToken).Password
    try {
        if (-not [string]::IsNullOrWhiteSpace($PlainToken)) {
            $PlainToken | & gh secret set CLOUDFLARE_CI_WORKERS_TOKEN --repo $Repository
            Write-Information "Registered secret: CLOUDFLARE_CI_WORKERS_TOKEN" -InformationAction Continue

            if ([string]::IsNullOrWhiteSpace($CloudflareAccountId)) {
                $AccountsResponse = Invoke-RestMethod -Method Get -Uri 'https://api.cloudflare.com/client/v4/accounts' -Headers @{
                    Authorization = "Bearer $PlainToken"
                }
                if ($AccountsResponse.result -and $AccountsResponse.result.Count -gt 0) {
                    $CloudflareAccountId = [string] $AccountsResponse.result[0].id
                    $CloudflareAccountId | & gh secret set CLOUDFLARE_ACCOUNT_ID --repo $Repository
                    Write-Information "Auto-discovered and registered secret: CLOUDFLARE_ACCOUNT_ID ($CloudflareAccountId)" -InformationAction Continue
                }
            }
        }
    }
    finally {
        $PlainToken = $null
    }
}

$Variables = @{
    PUBLIC_ADSENSE_CLIENT_ID = $AdSenseClientId
    PUBLIC_GA_MEASUREMENT_ID = $GaMeasurementId
}

foreach ($Entry in $Variables.GetEnumerator()) {
    if (-not [string]::IsNullOrWhiteSpace($Entry.Value)) {
        & gh variable set $Entry.Key --body $Entry.Value --repo $Repository
        Write-Information "Registered variable: $($Entry.Key)" -InformationAction Continue
    }
}

if (-not [string]::IsNullOrWhiteSpace($AdSenseClientId)) {
    $env:PUBLIC_ADSENSE_CLIENT_ID = $AdSenseClientId
    Push-Location -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')
    try {
        & node scripts/sync-ads-txt.mjs
    }
    finally {
        Pop-Location
    }
}
