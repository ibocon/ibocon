BeforeAll {
    . (Join-Path $PSScriptRoot '../Get-ProfileLanguageStats.ps1') -User 'fixture' -OutputPath 'unused'

    function New-Repository {
        param([hashtable] $Languages, [int] $Mine, [int] $Total)

        return [pscustomobject]@{ Languages = $Languages; MyCommits = $Mine; TotalCommits = $Total }
    }
}

Describe 'Get-WeightedLanguageShares' {
    It 'Given_TwoRepositories_When_Weighted_Then_BiggerCommitShareDominates' {
        # Given
        $repositories = @(
            (New-Repository -Languages @{ 'C#' = 1000 } -Mine 90 -Total 100),
            (New-Repository -Languages @{ 'JavaScript' = 1000 } -Mine 10 -Total 100)
        )

        # When
        $shares = Get-WeightedLanguageShares -Repositories $repositories

        # Then
        $shares[0].Name | Should -Be 'C#'
        $shares[0].Percent | Should -Be 90
    }

    It 'Given_NoMyCommits_When_Weighted_Then_RepositoryIsIgnored' {
        # Given
        $repositories = @(
            (New-Repository -Languages @{ 'Go' = 5000 } -Mine 0 -Total 50),
            (New-Repository -Languages @{ 'C#' = 100 } -Mine 5 -Total 5)
        )

        # When
        $shares = Get-WeightedLanguageShares -Repositories $repositories

        # Then
        $shares.Name | Should -Not -Contain 'Go'
    }

    It 'Given_MoreLanguagesThanLimit_When_Weighted_Then_RestIsGroupedAsOther' {
        # Given
        $languages = @{ 'A' = 50; 'B' = 30; 'C' = 15; 'D' = 5 }
        $repositories = @(New-Repository -Languages $languages -Mine 1 -Total 1)

        # When
        $shares = Get-WeightedLanguageShares -Repositories $repositories -Limit 2

        # Then
        $shares.Name | Should -Be @('A', 'B', 'Other')
        $shares[2].Percent | Should -Be 20
    }

    It 'Given_NoRepositories_When_Weighted_Then_ReturnsEmpty' {
        # Given
        $repositories = @()

        # When
        $shares = Get-WeightedLanguageShares -Repositories $repositories

        # Then
        $shares.Count | Should -Be 0
    }
}

Describe 'ConvertTo-LanguageSvg' {
    It 'Given_Shares_When_Rendered_Then_ContainsLanguagesAndScopeOnly' {
        # Given
        $shares = @([pscustomobject]@{ Name = 'C#'; Percent = 60.5 })

        # When
        $svg = ConvertTo-LanguageSvg -Shares $shares -Scope 'ibocon + BotanicSoft'

        # Then
        $svg | Should -Match 'C#'
        $svg | Should -Match '60.5%'
        $svg | Should -Match 'ibocon \+ BotanicSoft'
    }

    It 'Given_LanguageNameWithMarkup_When_Rendered_Then_IsEscaped' {
        # Given
        $shares = @([pscustomobject]@{ Name = '<script>'; Percent = 1 })

        # When
        $svg = ConvertTo-LanguageSvg -Shares $shares -Scope 'scope'

        # Then
        $svg | Should -Not -Match '<script>'
        $svg | Should -Match '&lt;script&gt;'
    }
}
