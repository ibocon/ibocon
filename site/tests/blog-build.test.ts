import { describe, it, expect } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Astro Blog Static Build Verification', () => {
  it('Given_BuiltPost_When_Inspected_Then_ReferencesReadableDesignCss', () => {
    // Given
    const distDir = resolve(process.cwd(), 'dist');
    const postHtmlPath = resolve(distDir, 'clean-architecture-rich-domain', 'index.html');
    const postHtml = readFileSync(postHtmlPath, 'utf-8');

    // When
    const stylesheetHref = postHtml.match(/<link rel="stylesheet" href="([^"]+\.css)">/)?.[1];

    // Then
    expect(stylesheetHref).toBeDefined();
    const stylesheetPath = resolve(distDir, stylesheetHref!.replace(/^\//, ''));
    const stylesheet = readFileSync(stylesheetPath, 'utf-8');
    expect(stylesheet).toMatch(/--prose-measure:\s*46rem/);
    expect(postHtml).toContain('class="container post-layout"');
  });

  it('Given_BlogMarkdownAndPublicAssets_When_Built_Then_GeneratesAdsTxtRssAndAnalyticsHtml', () => {
    // Given
    const distDir = resolve(process.cwd(), 'dist');
    const adsTxtPath = resolve(distDir, 'ads.txt');
    const rssXmlPath = resolve(distDir, 'rss.xml');

    // When
    const adsTxtExists = existsSync(adsTxtPath);
    const rssXmlExists = existsSync(rssXmlPath);

    // Then
    expect(adsTxtExists).toBe(true);
    expect(readFileSync(adsTxtPath, 'utf-8')).toContain('google.com, pub-');
    expect(rssXmlExists).toBe(true);
    expect(readFileSync(rssXmlPath, 'utf-8')).toContain('https://blog.botanicsoft.com');
  });

  it('Given_DraftIncidentCaseStudy_When_Built_Then_KeepsItOutOfPublicHtmlAndRss', () => {
    // Given
    const distDir = resolve(process.cwd(), 'dist');
    const draftPath = resolve(process.cwd(), '..', 'blog', 'kubernetes-alertmanager-postfix-open-relay.md');
    const postHtmlPath = resolve(distDir, 'kubernetes-alertmanager-postfix-open-relay', 'index.html');
    const rssXmlPath = resolve(distDir, 'rss.xml');

    // When
    const draft = readFileSync(draftPath, 'utf-8');
    const rssXml = readFileSync(rssXmlPath, 'utf-8');

    // Then
    expect(draft).toContain('draft: true');
    expect(existsSync(postHtmlPath)).toBe(false);
    expect(rssXml).not.toContain('kubernetes-alertmanager-postfix-open-relay');
  });

  it('Given_DevelopmentRoute_When_InspectingDraftContract_Then_IncludesDraftsAndShowsReviewBanner', () => {
    // Given
    const routePath = resolve(process.cwd(), 'src', 'pages', '[...slug].astro');

    // When
    const route = readFileSync(routePath, 'utf-8');

    // Then
    expect(route).toContain('const includeDrafts = import.meta.env.DEV;');
    expect(route).toContain('includeDrafts || !post.data.draft');
    expect(route).toContain('로컬 검토용 초안 · 공개 전 검토 중');
  });

  it('Given_DevelopmentHome_When_InspectingDraftContract_Then_IncludesDraftsOnlyLocally', () => {
    // Given
    const homePath = resolve(process.cwd(), 'src', 'pages', 'index.astro');

    // When
    const home = readFileSync(homePath, 'utf-8');

    // Then
    expect(home).toContain('const includeDrafts = import.meta.env.DEV;');
    expect(home).toContain('includeDrafts || !post.data.draft');
  });

  it('Given_AuthoringVersionOne_When_InspectingTheContentSchema_Then_AcceptsItsMetadata', () => {
    // Given
    const schemaPath = resolve(process.cwd(), 'src', 'content.config.ts');

    // When
    const schema = readFileSync(schemaPath, 'utf-8');

    // Then
    expect(schema).toContain('authoringVersion: z.literal(1).optional()');
    expect(schema).toContain("audience: z.enum(['topic-new-developer']).optional()");
    expect(schema).toContain("articleType: z.enum(['concept', 'tutorial', 'incident', 'design']).optional()");
  });

  it('Given_MermaidCodeBlock_When_InspectingRoute_Then_NormalizesTheDefinitionBeforeRendering', () => {
    // Given
    const routePath = resolve(process.cwd(), 'src', 'pages', '[...slug].astro');

    // When
    const route = readFileSync(routePath, 'utf-8');

    // Then
    expect(route).toContain('pre[data-language="mermaid"]');
    expect(route).toContain('const definition = block.textContent?.trim();');
    expect(route).toContain('block.textContent = definition;');
    expect(route).toContain("block.classList.add('mermaid');");
    expect(route).toContain('await mermaid.run({ nodes: mermaidBlocks });');
  });

  it('Given_CaPubClientId_When_FormattedForAdsTxt_Then_NormalizesToPubPrefix', async () => {
    // Given
    const { formatAdsTxtLine, normalizeAdSensePublisherId } = await import('../scripts/sync-ads-txt.mjs');

    // When
    const normalized = normalizeAdSensePublisherId('ca-pub-1234567890123456');
    const line = formatAdsTxtLine('ca-pub-1234567890123456');

    // Then
    expect(normalized).toBe('pub-1234567890123456');
    expect(line).toBe('google.com, pub-1234567890123456, DIRECT, f08c47fec0942fa0\n');
  });

  it('Given_WorkersConfigAndWorkflow_When_Inspected_Then_UsesWorkersStaticAssetsAndCiWorkersToken', () => {
    // Given
    const workflowPath = resolve(process.cwd(), '..', '.github', 'workflows', 'blog-deploy.yml');
    const wranglerPath = resolve(process.cwd(), 'wrangler.jsonc');

    // When
    const workflowContent = readFileSync(workflowPath, 'utf-8');
    const wranglerConfig = JSON.parse(readFileSync(wranglerPath, 'utf-8'));

    // Then
    expect(workflowContent).toContain('workflow_dispatch:');
    expect(workflowContent).not.toContain('push:');
    expect(workflowContent).toContain('secrets.CLOUDFLARE_CI_WORKERS_TOKEN');
    expect(workflowContent).toContain('command: deploy');
    expect(wranglerConfig.name).toBe('botanicsoft-blog');
    expect(wranglerConfig.assets.directory).toBe('./dist');
    expect(wranglerConfig.routes[0]).toEqual({
      pattern: 'blog.botanicsoft.com',
      custom_domain: true,
    });
  });
});
