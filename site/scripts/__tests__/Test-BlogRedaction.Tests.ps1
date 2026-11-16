BeforeAll {
    $script:GuardPath = Join-Path $PSScriptRoot '../Test-BlogRedaction.ps1' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:PolicyPath = Join-Path $PSScriptRoot '../blog-redaction-policy.json' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:FixtureRoot = Join-Path $TestDrive 'blog'
    $script:EvidenceRoot = Join-Path $TestDrive 'evidence'
    New-Item -ItemType Directory -Path $script:FixtureRoot, $script:EvidenceRoot | Out-Null

    function Invoke-RedactionFixture {
        param([string] $Body, [string[]] $EvidencePath = @(), [string] $AuthoringVersion = '1')

        @"
---
title: "비식별 검사 샘플"
authoringVersion: $AuthoringVersion
---
$Body
"@ | Set-Content -LiteralPath (Join-Path $script:FixtureRoot 'sample-post.md') -Encoding utf8

        $global:LASTEXITCODE = 0
        $arguments = @{ BlogRoot = $script:FixtureRoot; PolicyPath = $script:PolicyPath }
        if ($EvidencePath.Count -gt 0) { $arguments.EvidencePath = $EvidencePath }
        $output = & $script:GuardPath @arguments 2>&1
        [pscustomobject]@{ ExitCode = $global:LASTEXITCODE; Output = $output -join "`n" }
    }
}

Describe 'Test-BlogRedaction' {
    It 'Given_OnlyDocumentationAndLoopbackAddresses_When_Guarded_Then_Passes' {
        $result = Invoke-RedactionFixture -Body "원본 203.0.113.10 과 198.51.100.7, 127.0.0.1 만 쓴다."

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'blog-redaction\] OK'
    }

    It 'Given_AnAddressOutsideTheExampleRanges_When_Guarded_Then_FailsWithoutPrintingTheValue' {
        $result = Invoke-RedactionFixture -Body "발신 IP는 8.8.4.4 였다."

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-ip-not-example: sample-post.md:\d+ \(ipv4\)'
        $result.Output | Should -Not -Match '8\.8\.4\.4'
    }

    It 'Given_APrivateClusterAddress_When_Guarded_Then_Fails' {
        $result = Invoke-RedactionFixture -Body "노드는 10.0.4.17 이다."

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-ip-not-example'
    }

    It 'Given_AnInternalSubdomain_When_Guarded_Then_Fails' {
        $result = Invoke-RedactionFixture -Body "주소는 openbao.hanul.botanicsoft.com 이다."

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-internal-hostname'
    }

    It 'Given_ThePublicBlogHostAndRootDomain_When_Guarded_Then_Passes' {
        $result = Invoke-RedactionFixture -Body "blog.botanicsoft.com 과 botanicsoft.com 은 공개 주소다."

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AClusterInternalServiceName_When_Guarded_Then_Fails' {
        $result = Invoke-RedactionFixture -Body "호출은 postfix.mail.svc.cluster.local 로 갔다."

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-internal-hostname'
    }

    It 'Given_ATokenShapedValue_When_Guarded_Then_FailsWithoutPrintingTheValue' {
        $token = 'glsa_' + ('a1B2' * 6)
        $result = Invoke-RedactionFixture -Body "export TOKEN=$token"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-secret-pattern: sample-post.md:\d+ \(grafana-service-account-token\)'
        $result.Output | Should -Not -Match 'glsa_a1B2'
    }

    It 'Given_ARealLookingEmailInAV1Post_When_Guarded_Then_Fails' {
        $result = Invoke-RedactionFixture -Body "담당자는 kim@mangoslab.com 이다."

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-email-not-example'
    }

    It 'Given_AnExampleDomainEmail_When_Guarded_Then_Passes' {
        $result = Invoke-RedactionFixture -Body "발신자는 admin@example.com 이다."

        $result.ExitCode | Should -Be 0
    }

    It 'Given_ALegacyPostWithAThirdPartyEmail_When_Guarded_Then_Passes' {
        $result = Invoke-RedactionFixture -AuthoringVersion '0' -Body "예제 주소 mysite@nowhere.com"

        $result.ExitCode | Should -Be 0
    }

    It 'Given_EvidenceWhoseAddressSurvivesInThePost_When_Guarded_Then_FailsAsEvidenceLeak' {
        $evidence = Join-Path $script:EvidenceRoot 'report.xml'
        '<record><source_ip>8.8.4.4</source_ip><reporter>esa3.example-mx.eu</reporter></record>' | Set-Content -LiteralPath $evidence -Encoding utf8

        $result = Invoke-RedactionFixture -Body "보고서에는 8.8.4.4 가 찍혀 있었다." -EvidencePath $evidence

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-evidence-leak: sample-post.md:\d+ \(ipv4\)'
        $result.Output | Should -Not -Match '8\.8\.4\.4'
    }

    It 'Given_EvidenceWhoseHostnameSurvivesInThePost_When_Guarded_Then_FailsAsEvidenceLeak' {
        $evidence = Join-Path $script:EvidenceRoot 'report.xml'
        '<reporter>esa3.example-mx.eu</reporter>' | Set-Content -LiteralPath $evidence -Encoding utf8

        $result = Invoke-RedactionFixture -Body "수신 서버는 esa3.example-mx.eu 였다." -EvidencePath $evidence

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-redaction-evidence-leak: sample-post.md:\d+ \(hostname\)'
    }

    It 'Given_GzippedEvidenceWithAScrubbedPost_When_Guarded_Then_Passes' {
        $plain = Join-Path $script:EvidenceRoot 'report.xml'
        '<source_ip>8.8.4.4</source_ip>' | Set-Content -LiteralPath $plain -Encoding utf8
        $gz = Join-Path $script:EvidenceRoot 'report.xml.gz'
        $in = [IO.File]::OpenRead($plain)
        $out = [IO.File]::Create($gz)
        $gzip = [IO.Compression.GZipStream]::new($out, [IO.Compression.CompressionMode]::Compress)
        $in.CopyTo($gzip)
        $gzip.Dispose(); $out.Dispose(); $in.Dispose()

        $result = Invoke-RedactionFixture -Body "보고서에는 203.0.113.10 이 찍혀 있었다." -EvidencePath $gz

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'evidence=1'
    }

    It 'Given_AMissingEvidencePath_When_Guarded_Then_Fails' {
        { Invoke-RedactionFixture -Body '본문' -EvidencePath (Join-Path $script:EvidenceRoot 'nope.xml') } | Should -Throw '*blog-redaction-evidence-missing*'
    }
}
