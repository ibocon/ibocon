export interface TocHeading {
  depth: number;
  slug: string;
  text: string;
}

// remark-rehype가 각주 목록 앞에 만드는 제목의 id다. 목차에는 넣지 않는다.
export const footnoteHeadingSlug = 'footnote-label';

export function getTocHeadings<T extends TocHeading>(headings: readonly T[]): T[] {
  return headings.filter((heading) => heading.slug !== footnoteHeadingSlug);
}
