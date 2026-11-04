import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// ✅ Workers Static Assets 의 _redirects 형식. 슬래시 유무 두 형태를 모두 301 로 연결한다.
export function buildRedirects(manifest) {
  return manifest
    .flatMap(({ legacyPath, slug }) => [`${legacyPath} /${slug}/ 301`, `${legacyPath.replace(/\/$/, '')} /${slug}/ 301`])
    .sort()
    .join('\n') + '\n';
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const here = dirname(fileURLToPath(import.meta.url));
  const manifest = JSON.parse(readFileSync(resolve(here, 'blog-slugs.json'), 'utf8'));
  writeFileSync(resolve(here, '..', 'public', '_redirects'), buildRedirects(manifest), 'utf8');
}
