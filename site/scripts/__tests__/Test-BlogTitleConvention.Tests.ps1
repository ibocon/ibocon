BeforeAll {
    $script:GuardPath = Join-Path $PSScriptRoot '../Test-BlogTitleConvention.ps1' | Resolve-Path | Select-Object -ExpandProperty Path
    $script:FixtureRoot = Join-Path $TestDrive 'blog'
    $script:ManifestPath = Join-Path $TestDrive 'titles.json'
    $script:SlugManifestPath = Join-Path $TestDrive 'slugs.json'

    New-Item -ItemType Directory -Path $script:FixtureRoot | Out-Null
    Set-Content -LiteralPath (Join-Path $script:FixtureRoot 'sample-post.md') -Encoding utf8 -Value @'
---
title: "도메인 모델의 불변식을 지키는 방법: C#"
description: "fixture"
pubDate: 2026-11-05
tags: ["dotnet"]
---
'@
    Set-Content -LiteralPath $script:ManifestPath -Encoding utf8 -Value @'
[
  { "file": "sample-post.md", "title": "도메인 모델의 불변식을 지키는 방법: C#" }
]
'@
    Set-Content -LiteralPath $script:SlugManifestPath -Encoding utf8 -Value @'
[
  { "legacyPath": "/dotnet/sample/", "slug": "sample-post" }
]
'@
}

Describe 'Test-BlogTitleConvention' {
    BeforeEach {
        function Invoke-GuardFixture {
            param([string] $Title)

            $postPath = Join-Path $script:FixtureRoot 'sample-post.md'
            $content = Get-Content -Raw -LiteralPath $postPath
            $updated = [regex]::Replace($content, '(?m)^title:.*$', "title: `"$Title`"")
            Set-Content -LiteralPath $postPath -Encoding utf8 -Value $updated

            $output = & $script:GuardPath -BlogRoot $script:FixtureRoot -ManifestPath $script:ManifestPath -SlugManifestPath $script:SlugManifestPath 2>&1
            [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output -join "`n" }
        }
    }

    It 'Given_AConformingTitle_When_Guarded_Then_Passes' {
        $result = Invoke-GuardFixture -Title '도메인 모델의 불변식을 지키는 방법: C#'

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match 'blog-title-convention] OK'
    }

    It 'Given_ABracketPrefixedTitle_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Title '[C#] 도메인 모델의 불변식을 지키는 방법: 설계'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-title-prefix-forbidden'
    }

    It 'Given_ARecommendationEnding_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Title '도메인 모델을 자세히 알아보자: C# 설계'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-title-recommendation-ending-forbidden'
    }

    It 'Given_ASeparatorWithoutContext_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Title '도메인 모델을 설계하는 방법 - C#'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-title-context-separator-invalid'
    }

    It 'Given_AChangedTitleOutsideTheManifest_When_Guarded_Then_Fails' {
        $result = Invoke-GuardFixture -Title '다른 제목으로 바뀐 도메인 모델의 설계 방법: C#'

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'blog-title-manifest-title-drift'
    }

    It 'Given_AFileMissingFromTheManifest_When_Guarded_Then_Fails' {
        Add-Content -LiteralPath $script:ManifestPath -Value ' '
        Set-Content -LiteralPath (Join-Path $script:FixtureRoot 'other-post.md') -Encoding utf8 -Value @'
---
title: "다른 글의 제목을 검증하는 방법: 테스트"
description: "fixture"
pubDate: 2026-11-05
tags: ["dotnet"]
---
'@

        $result = & $script:GuardPath -BlogRoot $script:FixtureRoot -ManifestPath $script:ManifestPath -SlugManifestPath $script:SlugManifestPath 2>&1

        $LASTEXITCODE | Should -Be 1
        ($result -join "`n") | Should -Match 'blog-title-manifest-entry-missing'
    }
}
