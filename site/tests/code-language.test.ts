import { describe, expect, it } from 'vitest';
import { detectCodeLanguage } from '../scripts/code-language.mjs';
import { backfillCodeLanguages } from '../scripts/backfill-code-languages.mjs';

describe('Code block language backfill', () => {
  it('Given_JavaSource_When_Detected_Then_ReturnsJava', () => {
    // Given
    const code = '@Configuration\n@EnableWebSecurity\npublic class SecurityConfig extends WebSecurityConfigurerAdapter {\n  @Override\n  protected void configure(final HttpSecurity httpSecurity) throws Exception { }\n}';
    // When
    const language = detectCodeLanguage(code);
    // Then
    expect(language).toBe('java');
  });

  it('Given_PlainProse_When_Detected_Then_ReturnsText', () => {
    // Given
    const code = '이것은 코드가 아닌 설명 문장입니다';
    // When
    const language = detectCodeLanguage(code);
    // Then
    expect(language).toBe('text');
  });

  it('Given_MermaidAndBareFences_When_Backfilled_Then_OnlyBareFencesGainLanguage', () => {
    // Given
    const markdown = '```mermaid\ngraph LR\n```\n\n```\nSELECT 1;\n```';
    // When
    const result = backfillCodeLanguages(markdown, () => 'sql');
    // Then
    expect(result).toBe('```mermaid\ngraph LR\n```\n\n```sql\nSELECT 1;\n```');
  });
});
