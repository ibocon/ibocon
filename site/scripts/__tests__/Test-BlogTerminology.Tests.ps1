BeforeAll {
    $script:GuardPath = Join-Path $PSScriptRoot '../Test-BlogTerminology.ps1' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:PolicyPath = Join-Path $PSScriptRoot '../blog-authoring-policy.json' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:FixtureRoot = Join-Path $TestDrive 'blog'
    New-Item -ItemType Directory -Path $script:FixtureRoot | Out-Null

    function Invoke-TerminologyFixture {
        param([string] $Body, [bool] $OptIn = $true, [string] $Glossary)

        $glossaryPath = Join-Path $TestDrive 'glossary.json'
        if ([string]::IsNullOrEmpty($Glossary)) {
            $Glossary = @'
{ "schemaVersion": 1, "categories": [{ "key": "layer", "label": "레이어" }], "terms": [
  { "id": "application-layer", "term": "Application 레이어", "category": "layer", "definition": "유스케이스를 조율하는 레이어다.", "forbidden": ["어플리케이션 레이어", "어플리케이션 Layer", "App 레이어"] },
  { "id": "domain-layer", "term": "Domain 레이어", "category": "layer", "definition": "규칙을 담는 레이어다.", "forbidden": ["도메인 레이어"] }
] }
'@
        }

        Set-Content -LiteralPath $glossaryPath -Value $Glossary -Encoding utf8
        $version = if ($OptIn) { "authoringVersion: 1`n" } else { '' }
        "---`ntitle: `"샘플`"`n$version---`n$Body" | Set-Content -LiteralPath (Join-Path $script:FixtureRoot 'sample-post.md') -Encoding utf8

        $global:LASTEXITCODE = 0
        $output = & $script:GuardPath -BlogRoot $script:FixtureRoot -GlossaryPath $glossaryPath -PolicyPath $script:PolicyPath 2>&1
        [pscustomobject]@{ ExitCode = $global:LASTEXITCODE; Output = $output -join "`n" }
    }
}

Describe 'Test-BlogTerminology' {
    It 'Given_StandardTermsLinkedAtFirstUse_When_Guarded_Then_Passes' {
        $result = Invoke-TerminologyFixture -Body "[Application 레이어](/glossary/#application-layer)는 조율한다. 다음에는 Application 레이어를 그대로 쓴다.`n"

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'blog-terminology\] OK posts=1'
    }

    It 'Given_AForbiddenVariant_When_Guarded_Then_FailsWithLineAndTermId' {
        $result = Invoke-TerminologyFixture -Body "첫 줄이다.`n어플리케이션 레이어는 조율한다.`n"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-variant-term: sample-post.md:\d+ \[application-layer\]'
    }

    It 'Given_AppLayerAndMixedLanguageVariants_When_Guarded_Then_FailsForEach' {
        $result = Invoke-TerminologyFixture -Body "App 레이어를 쓴다.`n어플리케이션 Layer도 쓴다.`n"

        $result.ExitCode | Should -Be 1
        # 변종마다 한 줄씩, 서로 다른 줄에 있으므로 두 건이 보고된다.
        @($result.Output -split "`n" | Where-Object { $_ -match 'blog-terminology-variant-term: sample-post.md:\d+ \[application-layer\]' }).Count | Should -Be 2
    }

    It 'Given_ACaseOrSpacingVariant_When_Guarded_Then_FailsWithCaseVariant' {
        $result = Invoke-TerminologyFixture -Body "application 레이어를 쓴다. Domain레이어도 쓴다.`n"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-case-variant: sample-post.md:\d+ \[application-layer\]'
        $result.Output | Should -Match 'blog-terminology-case-variant: sample-post.md:\d+ \[domain-layer\]'
    }

    It 'Given_AnUnlinkedFirstOccurrence_When_Guarded_Then_FailsWithLinkMissing' {
        $result = Invoke-TerminologyFixture -Body "Application 레이어는 조율한다.`n"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-link-missing: sample-post.md:\d+ \[application-layer\]'
    }

    It 'Given_AFirstOccurrenceOnlyInAHeading_When_Guarded_Then_DoesNotCountTheHeading' {
        $result = Invoke-TerminologyFixture -Body "## Application 레이어는 무엇인가`n[Application 레이어](/glossary/#application-layer)를 본문에서 처음 쓴다.`n"

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AnUnknownGlossaryAnchor_When_Guarded_Then_FailsWithTargetUnknown' {
        $result = Invoke-TerminologyFixture -Body "[Application 레이어](/glossary/#no-such-term)를 쓴다.`n"

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-link-target-unknown: sample-post.md:\d+'
    }

    It 'Given_VariantsInsideCodeFenceAndInlineCode_When_Guarded_Then_Passes' {
        $result = Invoke-TerminologyFixture -Body @'
변종은 `어플리케이션 레이어`처럼 코드로 쓴다.

```text
App 레이어
```
'@

        $result.ExitCode | Should -Be 0
    }

    It 'Given_ALegacyPostWithoutOptIn_When_Guarded_Then_IsNotChecked' {
        $result = Invoke-TerminologyFixture -OptIn $false -Body "어플리케이션 레이어를 쓴다.`n"

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'posts=0'
    }

    It 'Given_AGlossaryWithDuplicateIds_When_Guarded_Then_FailsWithGlossaryInvalid' {
        $duplicate = '{ "schemaVersion": 1, "categories": [], "terms": [ { "id": "a-term", "term": "가", "category": "x", "definition": "d", "forbidden": [] }, { "id": "a-term", "term": "나", "category": "x", "definition": "d", "forbidden": [] } ] }'
        $result = Invoke-TerminologyFixture -Body "본문이다.`n" -Glossary $duplicate

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-glossary-invalid: id:a-term'
    }

    It 'Given_AForbiddenSurfaceThatCollidesWithAnotherTerm_When_Guarded_Then_FailsWithGlossaryInvalid' {
        $collision = '{ "schemaVersion": 1, "categories": [], "terms": [ { "id": "one", "term": "가나", "category": "x", "definition": "d", "forbidden": ["다라"] }, { "id": "two", "term": "다라", "category": "x", "definition": "d", "forbidden": [] } ] }'
        $result = Invoke-TerminologyFixture -Body "본문이다.`n" -Glossary $collision

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-glossary-invalid: surface:다라'
    }

    It 'Given_AnOccurrenceInsideAnExternalLink_When_Guarded_Then_ItIsNotTheFirstOccurrence' {
        $result = Invoke-TerminologyFixture -Body "[Domain 레이어 설명](https://example.com/a)을 읽었다. [Domain 레이어](/glossary/#domain-layer)를 쓴다.`n"

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AnAsciiTermInsideAnotherEnglishWord_When_Guarded_Then_DoesNotMatchIt' {
        $glossary = '{ "schemaVersion": 1, "categories": [], "terms": [ { "id": "orm", "term": "ORM", "category": "x", "definition": "d", "forbidden": [] } ] }'
        $result = Invoke-TerminologyFixture -Body "platform과 information은 영어 단어다. [ORM](/glossary/#orm)은 용어다.`n" -Glossary $glossary

        $result.ExitCode | Should -Be 0
    }

    It 'Given_AnAsciiTermWithDifferentCase_When_Guarded_Then_StillFailsWithCaseVariant' {
        $glossary = '{ "schemaVersion": 1, "categories": [], "terms": [ { "id": "orm", "term": "ORM", "category": "x", "definition": "d", "forbidden": [] } ] }'
        $result = Invoke-TerminologyFixture -Body "[ORM](/glossary/#orm)과 orm을 섞어 쓴다.`n" -Glossary $glossary

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-terminology-case-variant: sample-post.md:\d+ \[orm\]'
    }
}
