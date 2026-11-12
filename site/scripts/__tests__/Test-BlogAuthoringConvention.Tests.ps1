BeforeAll {
    $script:GuardPath = Join-Path $PSScriptRoot '../Test-BlogAuthoringConvention.ps1' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:PolicyPath = Join-Path $PSScriptRoot '../blog-authoring-policy.json' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:FixtureRoot = Join-Path $TestDrive 'blog'
    New-Item -ItemType Directory -Path $script:FixtureRoot | Out-Null
}

Describe 'Test-BlogAuthoringConvention' {
    BeforeEach {
        function Invoke-GuardFixture {
            param(
                [string] $ArticleType = 'concept',
                [string] $Audience = 'topic-new-developer',
                [string] $Description = '이 글은 개발자가 낯선 기술의 문제와 동작 원리를 이해하고 자신의 환경에서 확인할 판단 기준, 검증 방법, 적용할 때 주의할 조건까지 충분히 설명합니다.',
                [string] $Body
            )

            @"
---
title: "작성 기준을 검증하는 방법: 기술 블로그"
description: "$Description"
pubDate: 2026-11-11
tags: ["architecture"]
authoringVersion: 1
audience: "$Audience"
articleType: "$ArticleType"
---
$Body
"@ | Set-Content -LiteralPath (Join-Path $script:FixtureRoot 'sample-post.md') -Encoding utf8

            # PowerShell scripts that complete successfully do not always create
            # LASTEXITCODE in a fresh Pester worker under StrictMode.
            $global:LASTEXITCODE = 0
            $output = & $script:GuardPath -BlogRoot $script:FixtureRoot -PolicyPath $script:PolicyPath 2>&1
            [pscustomobject]@{ ExitCode = $global:LASTEXITCODE; Output = $output -join "`n" }
        }
    }

    It 'Given_AConformingConceptPost_When_Guarded_Then_Passes' {
        $result = Invoke-GuardFixture -Body @'
## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나
독자가 얻을 결과를 먼저 설명한다.

## 알아야 할 최소 개념
용어를 역할부터 설명한다.

## 동작 원리
원인과 결과를 연결한다.

## 적용할 때 확인할 점
점검 행동을 제시한다.

## 마무리: 다음 점검에서 확인할 한 가지
핵심 판단을 정리한다.
'@

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'blog-authoring-convention] OK'
    }

    It 'Given_AConformingTutorialPost_When_Guarded_Then_Passes' {
        $result = Invoke-GuardFixture -ArticleType 'tutorial' -Body @'
## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나
작업의 결과를 설명한다.

## 시작하기 전
전제 조건을 확인한다.

## 따라 하기
단계를 수행한다.

## 검증
기대 결과를 확인한다.

## 문제 해결
실패 신호를 확인한다.

## 마무리: 다음 점검에서 확인할 한 가지
다음 행동을 정리한다.
'@

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AMissingAudience_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Audience '' -Body "## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나`n## 알아야 할 최소 개념`n## 동작 원리`n## 적용할 때 확인할 점`n## 마무리: 다음 점검에서 확인할 한 가지"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-authoring-audience-missing'
    }

    It 'Given_AShortDescription_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Description '짧은 설명' -Body "## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나`n## 알아야 할 최소 개념`n## 동작 원리`n## 적용할 때 확인할 점`n## 마무리: 다음 점검에서 확인할 한 가지"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-authoring-description-length-invalid'
    }

    It 'Given_AConceptPostMissingItsRequiredSection_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Body "## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나`n## 알아야 할 최소 개념`n## 마무리: 다음 점검에서 확인할 한 가지"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-authoring-required-section-missing'
    }

    It 'Given_AnImageWithEmptyAltText_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Body "## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나`n## 알아야 할 최소 개념`n## 동작 원리`n## 적용할 때 확인할 점`n![](/diagram.png)`n## 마무리: 다음 점검에서 확인할 한 가지"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-authoring-image-alt-missing'
    }

    It 'Given_AConformingIncidentPostWithQuestionAliases_When_Guarded_Then_Passes' {
        $result = Invoke-GuardFixture -ArticleType 'incident' -Body @'
## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나
독자가 확인할 위험과 결과를 먼저 설명한다.

## 영향: 알림 relay가 대량 발송 경로가 되면 무엇이 달라지나
관찰 신호와 영향을 구분한다.

## 즉시 차단: 정상 알림을 보존하며 추가 발송을 멈추는 순서
정상 경로를 보존하는 순서를 설명한다.

## 원인: 외부 노출과 신뢰 경계가 겹친 방식
원인과 조건을 연결한다.

## 재발 방지: 네 가지 경계를 함께 점검하는 방법
다음 점검 기준을 제시한다.

## 마무리: 다음 점검에서 확인할 한 가지
다음 행동을 정리한다.
'@

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AnIncidentPostMissingPreventionAlias_When_Guarded_Then_FailsWithRole' {
        $result = Invoke-GuardFixture -ArticleType 'incident' -Body @'
## 핵심 요약: 어떤 위험을 막고 무엇을 확인하나
독자가 확인할 위험과 결과를 먼저 설명한다.

## 영향: 알림 relay가 대량 발송 경로가 되면 무엇이 달라지나
관찰 신호와 영향을 구분한다.

## 즉시 차단: 정상 알림을 보존하며 추가 발송을 멈추는 순서
정상 경로를 보존하는 순서를 설명한다.

## 원인: 외부 노출과 신뢰 경계가 겹친 방식
원인과 조건을 연결한다.

## 마무리: 다음 점검에서 확인할 한 가지
다음 행동을 정리한다.
'@

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-authoring-required-section-missing: sample-post.md#prevention'
    }
}
