BeforeAll {
    . (Join-Path $PSScriptRoot '../Test-ProfileTechStack.ps1') -ReadmePath 'unused' -ResumePath 'unused'

    $script:ReadmeFixture = @'
## 🛠 기술 스택 (Tech Stack)

### 언어
![C#](https://img.shields.io/badge/C%23-239120?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge)

---
'@

    $script:ResumeFixture = @'
## 기술 스택

### 언어

`C#` · `Python`

---
'@
}

Describe 'Get-ReadmeBadges' {
    It 'Given_Readme_When_Parsed_Then_ReturnsLabelAndUrl' {
        # Given
        $markdown = $script:ReadmeFixture

        # When
        $badges = @(Get-ReadmeBadges -Markdown $markdown)

        # Then
        $badges.Label | Should -Be @('C#', 'Python')
    }
}

Describe 'Get-ResumeTechStack' {
    It 'Given_Resume_When_Parsed_Then_ReturnsBacktickTokens' {
        # Given
        $markdown = $script:ResumeFixture

        # When
        $stack = @(Get-ResumeTechStack -Markdown $markdown)

        # Then
        $stack | Should -Be @('C#', 'Python')
    }
}

Describe 'Test-TechStackBadges' {
    It 'Given_MatchingBadges_When_Tested_Then_NoProblems' {
        # Given
        $badges = @(Get-ReadmeBadges -Markdown $script:ReadmeFixture)
        $stack = @(Get-ResumeTechStack -Markdown $script:ResumeFixture)

        # When
        $problems = @(Test-TechStackBadges -Badges $badges -ResumeStack $stack)

        # Then
        $problems.Count | Should -Be 0
    }

    It 'Given_UnescapedHash_When_Tested_Then_ReportsProblem' {
        # Given
        $badges = @([pscustomobject]@{ Label = 'C#'; Url = 'https://img.shields.io/badge/C#-239120?style=for-the-badge' })

        # When
        $problems = @(Test-TechStackBadges -Badges $badges -ResumeStack @('C#'))

        # Then
        $problems | Should -Match "이스케이프되지 않은 '#'"
    }

    It 'Given_BadgeNotInResume_When_Tested_Then_ReportsProblem' {
        # Given
        $badges = @([pscustomobject]@{ Label = 'Go'; Url = 'https://img.shields.io/badge/Go-00ADD8' })

        # When
        $problems = @(Test-TechStackBadges -Badges $badges -ResumeStack @('C#'))

        # Then
        $problems | Should -Match '이력서 기술 스택에 없다'
    }

    It 'Given_AliasLabel_When_Tested_Then_MapsToResumeName' {
        # Given
        $badges = @([pscustomobject]@{ Label = '.NET MAUI'; Url = 'https://img.shields.io/badge/.NET_MAUI-512BD4' })

        # When
        $problems = @(Test-TechStackBadges -Badges $badges -ResumeStack @('.NET MAUI Blazor Hybrid'))

        # Then
        $problems.Count | Should -Be 0
    }

    It 'Given_DuplicateLabel_When_Tested_Then_ReportsProblem' {
        # Given
        $badge = [pscustomobject]@{ Label = 'C#'; Url = 'https://img.shields.io/badge/C%23-239120' }

        # When
        $problems = @(Test-TechStackBadges -Badges @($badge, $badge) -ResumeStack @('C#'))

        # Then
        $problems | Should -Match '중복된다'
    }
}
