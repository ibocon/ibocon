const WORDS_PER_MINUTE = 300;

type PostPresentationInput = {
  coverImage?: string;
  tags: readonly string[];
};

export type PostPresentation = {
  coverImage: string;
  readingMinutes: number;
};

export function getPostPresentation(post: PostPresentationInput, markdown: string): PostPresentation {
  return {
    coverImage: post.coverImage ?? findFirstLocalMarkdownImage(markdown) ?? getTagFallbackCover(post.tags[0]),
    readingMinutes: getReadingMinutes(markdown),
  };
}

function findFirstLocalMarkdownImage(markdown: string): string | undefined {
  const prose = markdown.replace(/^```[\s\S]*?^```$/gm, '');
  const match = /!\[[^\]]*\]\((\/[^\s)]+)(?:\s+['"][^)]*['"])?\)/.exec(prose);

  return match?.[1];
}

function getTagFallbackCover(tag: string | undefined): string {
  const label = (tag ?? 'engineering').replace(/[^a-z0-9-]/gi, '').slice(0, 24) || 'engineering';
  const hue = [...label].reduce((total, character) => total + character.charCodeAt(0), 0) % 360;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" role="img" aria-label="${label} cover"><defs><linearGradient id="g" x1="0" x2="1" y1="0" y2="1"><stop stop-color="hsl(${hue} 58% 33%)"/><stop offset="1" stop-color="hsl(${(hue + 42) % 360} 68% 18%)"/></linearGradient></defs><rect width="1200" height="630" fill="url(#g)"/><circle cx="940" cy="160" r="250" fill="none" stroke="white" stroke-opacity=".18" stroke-width="56"/><path d="M120 490 410 200l170 170 130-130 370 250H120Z" fill="white" fill-opacity=".14"/><text x="120" y="470" fill="white" font-family="system-ui, sans-serif" font-size="68" font-weight="700">${label}</text></svg>`;

  return `data:image/svg+xml,${encodeURIComponent(svg)}`;
}

function getReadingMinutes(markdown: string): number {
  const readableText = markdown
    .replace(/^```[\s\S]*?^```$/gm, '')
    .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/[`*_>#|~-]/g, ' ');
  const koreanCharacters = (readableText.match(/[\uac00-\ud7a3]/g) ?? []).length;
  const words = readableText.match(/[A-Za-z0-9]+(?:['’-][A-Za-z0-9]+)*/g) ?? [];

  return Math.max(1, Math.ceil((koreanCharacters + words.length) / WORDS_PER_MINUTE));
}
