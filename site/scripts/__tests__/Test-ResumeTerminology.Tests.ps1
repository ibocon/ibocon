BeforeAll {
    $script:GuardPath = Join-Path $PSScriptRoot '../Test-ResumeTerminology.ps1' | Resolve-Path | Select-Object -ExpandProperty Path

    function New-ResumeFixture {
        param([string] $Root, [string] $Body)

        $resume = Join-Path $Root 'resume'
        New-Item -ItemType Directory -Path $resume -Force | Out-Null
        Set-Content -LiteralPath (Join-Path $resume 'glossary.md') -Encoding utf8 -Value @'
# 이력서 용어집

| ID | 표준 표기 | 금지 표기 |
| --- | --- | --- |
| on-premises | 온프레미스 | On-Premise |
'@
        Set-Content -LiteralPath (Join-Path $resume 'resume-yegun-kim.md') -Encoding utf8 -Value $Body
        return $resume
    }

    function Invoke-Guard {
        param([string] $ResumeRoot)

        $global:LASTEXITCODE = 0
        $output = & pwsh -NoProfile -File $script:GuardPath -ResumeRoot $ResumeRoot 2>&1 | Out-String
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    }
}

Describe 'Test-ResumeTerminology' {
    It 'Given_StandardResumeLabels_When_GuardRuns_Then_Passes' {
        $resume = New-ResumeFixture -Root $TestDrive -Body "## 상세 포트폴리오`n`n온프레미스 Kubernetes를 운영한다."

        $result = Invoke-Guard -ResumeRoot $resume

        $result.ExitCode | Should -Be 0
        $result.Output | Should -Match '\[resume-terminology\] OK'
    }

    It 'Given_ForbiddenTerm_When_GuardRuns_Then_Fails' {
        $resume = New-ResumeFixture -Root $TestDrive -Body 'On-Premise Kubernetes를 운영한다.'

        $result = Invoke-Guard -ResumeRoot $resume

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'resume-terminology-forbidden-term'
    }

    It 'Given_ParentheticalHeading_When_GuardRuns_Then_Fails' {
        $resume = New-ResumeFixture -Root $TestDrive -Body '## 상세 포트폴리오 (Domain Hub)'

        $result = Invoke-Guard -ResumeRoot $resume

        $result.ExitCode | Should -Be 1
        $result.Output | Should -Match 'resume-presentation-parenthetical-label'
    }
}
