export const HOME_PAGE_SIZE = 12;

export interface PageSlice<T> {
  items: T[];
  page: number;
  totalPages: number;
  prevHref: string | null;
  nextHref: string | null;
}

export function pagePath(basePath: string, page: number): string {
  return page <= 1 ? basePath : `${basePath}page/${page}/`;
}

export function paginate<T>(items: readonly T[], pageSize: number, basePath: string): PageSlice<T>[] {
  const totalPages = Math.max(1, Math.ceil(items.length / pageSize));
  return Array.from({ length: totalPages }, (_, index) => {
    const page = index + 1;
    return {
      items: items.slice(index * pageSize, (index + 1) * pageSize),
      page,
      totalPages,
      prevHref: page > 1 ? pagePath(basePath, page - 1) : null,
      nextHref: page < totalPages ? pagePath(basePath, page + 1) : null,
    };
  });
}
