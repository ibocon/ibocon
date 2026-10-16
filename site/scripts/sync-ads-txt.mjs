// ✅ PUBLIC_ADSENSE_CLIENT_ID 환경 변수에서 pub-ID를 추출해 public/ads.txt를 자동 갱신
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';

export function normalizeAdSensePublisherId(rawClientId) {
  const trimmed = (rawClientId ?? '').trim();
  if (!trimmed) {
    return 'pub-0000000000000000';
  }
  if (trimmed.startsWith('ca-pub-')) {
    return trimmed.slice(3);
  }
  if (trimmed.startsWith('pub-')) {
    return trimmed;
  }
  return `pub-${trimmed}`;
}

export function formatAdsTxtLine(rawClientId) {
  const publisherId = normalizeAdSensePublisherId(rawClientId);
  return `google.com, ${publisherId}, DIRECT, f08c47fec0942fa0\n`;
}

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const targetPath = resolve(process.cwd(), 'public', 'ads.txt');
  const content = formatAdsTxtLine(process.env.PUBLIC_ADSENSE_CLIENT_ID);
  writeFileSync(targetPath, content, 'utf-8');
}
