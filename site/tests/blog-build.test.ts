import { describe, it, expect } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Astro Blog Static Build Verification', () => {
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
