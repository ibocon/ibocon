import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Blog workflow contract', () => {
  it('keeps deployment manual and starts the README updater after a successful deploy', () => {
    const deploy = readFileSync(resolve(process.cwd(), '..', '.github/workflows/blog-deploy.yml'), 'utf8');
    const posts = readFileSync(resolve(process.cwd(), '..', '.github/workflows/blog-posts.yml'), 'utf8');
    expect(deploy).toContain('name: Build and Deploy Blog to Cloudflare Workers');
    expect(deploy).toContain('workflow_dispatch:');
    expect(deploy).not.toMatch(/^\s*push:/m);
    expect(posts).toContain("- 'Build and Deploy Blog to Cloudflare Workers'");
    expect(posts).toContain('github.event.workflow_run.conclusion == \'success\'');
  });
});
