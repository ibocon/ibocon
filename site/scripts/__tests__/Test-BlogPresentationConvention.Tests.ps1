BeforeAll {
    $script:WrapperPath = Join-Path $PSScriptRoot '../Test-BlogPresentationConvention.ps1' | Resolve-Path | Select-Object -ExpandProperty Path

    function New-WideDiagramBlog {
        param([Parameter(Mandatory)] [string] $Root)

        $Blog = Join-Path -Path $Root -ChildPath 'blog'
        New-Item -ItemType Directory -Path $Blog -Force | Out-Null
        $Post = "---`ntitle: ""fixture""`nauthoringVersion: 1`n---`n## 요약`n`n``````mermaid`nflowchart LR`n  A[a] --> B[b] --> C[c] --> D[d] --> E[e]`n``````n"
        Set-Content -LiteralPath (Join-Path $Blog 'fixture.md') -Value $Post -Encoding utf8
        return $Blog
    }

    function Invoke-Wrapper {
        param([string[]] $Arguments = @())

        $global:LASTEXITCODE = 0
        $Output = & pwsh -NoProfile -File $script:WrapperPath @Arguments 2>&1 | Out-String
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $Output }
    }
}

Describe 'Test-BlogPresentationConvention' {
    # 이 테스트가 실패하면 wrapper가 아니라 실제 blog/ 또는 site/ 가 표시 품질 규칙을 어긴 것이다.
    It 'Given_CurrentRepository_When_WrapperRuns_Then_Passes' {
        # Given
        $Arguments = @()

        # When
        $Result = Invoke-Wrapper -Arguments $Arguments

        # Then
        $Result.ExitCode | Should -Be 0
        $Result.Output | Should -Match 'technical-blog-presentation-guard\] OK'
    }

    It 'Given_WideHorizontalDiagram_When_WrapperRuns_Then_ReportsHorizontalChainTooLong' {
        # Given
        $Blog = New-WideDiagramBlog -Root $TestDrive

        # When
        $Result = Invoke-Wrapper -Arguments @('-ContentRoot', $Blog)

        # Then
        $Result.ExitCode | Should -Be 1
        $Result.Output | Should -Match 'technical-blog-presentation-diagram-horizontal-chain-too-long'
    }

    It 'Given_MissingGuardPath_When_WrapperRuns_Then_ThrowsGuardMissing' {
        # Given
        $MissingGuard = Join-Path $TestDrive 'missing.ps1'

        # When
        $Result = Invoke-Wrapper -Arguments @('-GuardPath', $MissingGuard)

        # Then
        $Result.ExitCode | Should -Not -Be 0
        $Result.Output | Should -Match 'blog-presentation-guard-missing'
    }
}
