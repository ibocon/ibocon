export interface UsagePost {
  id: string;
  title: string;
  body: string;
}

export interface UsageLink {
  id: string;
  title: string;
}

const GLOSSARY_LINK = /\]\(\/glossary\/#([a-z0-9]+(?:-[a-z0-9]+)*)\)/g;

export function collectGlossaryUsage(
  posts: readonly UsagePost[],
  termIds: readonly string[],
): ReadonlyMap<string, readonly UsageLink[]> {
  const usage = new Map<string, UsageLink[]>(termIds.map((id) => [id, []]));
  for (const post of posts) {
    // 한 글이 같은 용어를 여러 번 링크해도 한 번만 센다.
    const linked = new Set([...post.body.matchAll(GLOSSARY_LINK)].map((match) => match[1]));
    for (const id of linked) {
      // 용어집에 없는 앵커는 무시한다(표기 가드가 별도로 막는다).
      usage.get(id)?.push({ id: post.id, title: post.title });
    }
  }

  return usage;
}
