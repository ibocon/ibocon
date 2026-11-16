[CmdletBinding()]
param(
    [string] $BlogRoot = (Join-Path $PSScriptRoot '../../blog'),
    [string] $PolicyPath = (Join-Path $PSScriptRoot 'blog-redaction-policy.json'),
    # 원본 증거(로그, 보고서 등)가 있으면 그 안의 IP·호스트·이메일이 글에 남았는지 대조한다.
    [string[]] $EvidencePath = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ipv4Pattern = '(?<![\d.])(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)\.){3}(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(?![\d.])'
$hostPattern = '(?<![A-Za-z0-9.-])(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}(?![A-Za-z0-9-])'
$emailPattern = '(?<![A-Za-z0-9._%+-])[A-Za-z0-9._%+-]+@(?<domain>(?:[A-Za-z0-9-]+\.)+[A-Za-z]{2,})(?![A-Za-z0-9-])'

function ConvertTo-IpNumber {
    param([string] $Ip)

    $octets = $Ip.Split('.') | ForEach-Object { [uint32] $_ }
    return ($octets[0] -shl 24) -bor ($octets[1] -shl 16) -bor ($octets[2] -shl 8) -bor $octets[3]
}

function Test-IpAllowed {
    param([string] $Ip, [string[]] $Cidrs)

    $ipNumber = ConvertTo-IpNumber -Ip $Ip
    foreach ($cidr in $Cidrs) {
        $base, $bits = $cidr.Split('/')
        $prefix = [int] $bits
        $mask = if ($prefix -eq 0) { [uint32] 0 } else { [uint32]::MaxValue -shl (32 - $prefix) }
        if (($ipNumber -band $mask) -eq ((ConvertTo-IpNumber -Ip $base) -band $mask)) {
            return $true
        }
    }

    return $false
}

function Test-HostnameAllowed {
    param([string] $Name, [object] $Policy)

    return @($Policy.hostnames.allowed | Where-Object { $_ -ieq $Name }).Count -gt 0
}

function Read-EvidenceText {
    param([string] $Path)

    switch ([IO.Path]::GetExtension($Path).ToLowerInvariant()) {
        '.gz' {
            $file = [IO.File]::OpenRead($Path)
            $gzip = [IO.Compression.GZipStream]::new($file, [IO.Compression.CompressionMode]::Decompress)
            $reader = [IO.StreamReader]::new($gzip)
            try { return $reader.ReadToEnd() } finally { $reader.Dispose(); $gzip.Dispose(); $file.Dispose() }
        }
        '.zip' {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [IO.Compression.ZipFile]::OpenRead($Path)
            try {
                return (@($zip.Entries | Where-Object { $_.Length -gt 0 } | ForEach-Object {
                    $reader = [IO.StreamReader]::new($_.Open())
                    try { $reader.ReadToEnd() } finally { $reader.Dispose() }
                }) -join "`n")
            }
            finally { $zip.Dispose() }
        }
        default { return Get-Content -Raw -LiteralPath $Path }
    }
}

function Get-EvidenceTokens {
    param([string[]] $Paths, [object] $Policy)

    $tokens = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::OrdinalIgnoreCase)
    $allowedTokens = @($Policy.evidence.allowedTokens)

    foreach ($path in $Paths) {
        $resolved = [IO.Path]::GetFullPath($path)
        if (-not (Test-Path -LiteralPath $resolved)) {
            throw "blog-redaction-evidence-missing: $path"
        }

        $files = if (Test-Path -LiteralPath $resolved -PathType Container) {
            Get-ChildItem -LiteralPath $resolved -File -Recurse | ForEach-Object FullName
        }
        else {
            @($resolved)
        }

        foreach ($file in $files) {
            $text = Read-EvidenceText -Path $file
            foreach ($m in [regex]::Matches($text, $ipv4Pattern)) {
                if (-not (Test-IpAllowed -Ip $m.Value -Cidrs @($Policy.ipv4.allowedCidrs))) {
                    $tokens[$m.Value] = 'ipv4'
                }
            }
            foreach ($m in [regex]::Matches($text, $emailPattern)) {
                if ($allowedTokens -notcontains $m.Value -and $allowedTokens -notcontains $m.Groups['domain'].Value) {
                    $tokens[$m.Value] = 'email'
                }
            }
            foreach ($m in [regex]::Matches($text, $hostPattern)) {
                if ($allowedTokens -notcontains $m.Value -and -not ($m.Value -match '^\d+(\.\d+)+$')) {
                    $tokens[$m.Value] = 'hostname'
                }
            }
        }
    }

    return $tokens
}

$resolvedBlogRoot = [IO.Path]::GetFullPath($BlogRoot)
$policy = Get-Content -Raw -LiteralPath ([IO.Path]::GetFullPath($PolicyPath)) | ConvertFrom-Json
$violations = [Collections.Generic.List[string]]::new()
$evidenceTokens = if ($EvidencePath.Count -gt 0) { Get-EvidenceTokens -Paths $EvidencePath -Policy $policy } else { $null }
$posts = @(Get-ChildItem -LiteralPath $resolvedBlogRoot -File -Filter '*.md' | Sort-Object Name)

# 위반 값은 출력하지 않는다. 로그에 값이 다시 남으면 비식별의 의미가 사라진다.
function Add-Finding {
    param([string] $Code, [string] $Post, [int] $Line, [string] $Kind)

    $violations.Add("${Code}: ${Post}:${Line} ($Kind)")
}

foreach ($post in $posts) {
    $raw = Get-Content -Raw -LiteralPath $post.FullName
    $isV1 = $raw -match '(?m)^authoringVersion:\s*1\s*$'
    $lines = $raw -split '\r?\n'

    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        $number = $i + 1

        foreach ($m in [regex]::Matches($line, $ipv4Pattern)) {
            if (-not (Test-IpAllowed -Ip $m.Value -Cidrs @($policy.ipv4.allowedCidrs))) {
                Add-Finding -Code 'blog-redaction-ip-not-example' -Post $post.Name -Line $number -Kind 'ipv4'
            }
        }

        foreach ($secret in $policy.secretPatterns) {
            if ([regex]::IsMatch($line, [string] $secret.pattern)) {
                Add-Finding -Code 'blog-redaction-secret-pattern' -Post $post.Name -Line $number -Kind ([string] $secret.id)
            }
        }

        foreach ($m in [regex]::Matches($line, $hostPattern)) {
            $name = $m.Value
            $isInternal = @($policy.hostnames.forbiddenSuffixes | Where-Object {
                $name -ieq $_ -or $name.EndsWith(".$_", [StringComparison]::OrdinalIgnoreCase)
            }).Count -gt 0
            if ($isInternal -and -not (Test-HostnameAllowed -Name $name -Policy $policy)) {
                Add-Finding -Code 'blog-redaction-internal-hostname' -Post $post.Name -Line $number -Kind 'hostname'
            }
        }

        foreach ($pattern in $policy.hostnames.forbiddenPatterns) {
            if ([regex]::IsMatch($line, [string] $pattern)) {
                Add-Finding -Code 'blog-redaction-internal-hostname' -Post $post.Name -Line $number -Kind 'cluster-internal-name'
            }
        }

        if ($isV1) {
            foreach ($m in [regex]::Matches($line, $emailPattern)) {
                $domain = $m.Groups['domain'].Value
                if (@($policy.email.allowedDomains | Where-Object { $_ -ieq $domain }).Count -eq 0) {
                    Add-Finding -Code 'blog-redaction-email-not-example' -Post $post.Name -Line $number -Kind 'email'
                }
            }
        }

        if ($null -ne $evidenceTokens) {
            foreach ($token in $evidenceTokens.Keys) {
                $pattern = "(?<![A-Za-z0-9.-])$([regex]::Escape($token))(?![A-Za-z0-9-])"
                if ([regex]::IsMatch($line, $pattern, 'IgnoreCase')) {
                    Add-Finding -Code 'blog-redaction-evidence-leak' -Post $post.Name -Line $number -Kind $evidenceTokens[$token]
                }
            }
        }
    }
}

if ($violations.Count -gt 0) {
    $violations | Sort-Object -Unique | ForEach-Object { Write-Output "::error::$_" }
    exit 1
}

$mode = if ($null -ne $evidenceTokens) { "evidence=$($evidenceTokens.Count)" } else { 'evidence=none' }
Write-Output "[blog-redaction] OK posts=$($posts.Count) $mode"
