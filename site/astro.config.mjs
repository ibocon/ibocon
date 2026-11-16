// ✅ Cloudflare botanicsoft.com 도메인 및 정적 MPA 빌드 설정
import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://blog.botanicsoft.com',
  output: 'static',
  build: {
    inlineStylesheets: 'never',
  },
  integrations: [sitemap()],
  markdown: {
    shikiConfig: {
      theme: 'github-dark',
      wrap: true,
    },
    // 각주 보조 문구는 기본 영문이라 한국어로 바꾼다.
    remarkRehype: {
      footnoteLabel: '각주',
      footnoteBackLabel: '본문으로 돌아가기',
    },
  },
});
