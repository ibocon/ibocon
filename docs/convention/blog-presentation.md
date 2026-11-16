# 블로그 표시 품질 컨벤션

## 적용 방법

`authoringVersion: 1` 글과 사이트 스타일, 커버 자산에 적용한다. `site/scripts/Test-BlogPresentationConvention.ps1`이 이 문서의 기계 검증 가능한 규칙을 검사하고, 수치는 `site/scripts/blog-presentation-policy.json`이 소유한다. 판단 기준과 예시는 [표시 품질 가이드](../guide/blog-presentation-guide.md)를 따른다. 글 구조 규칙은 [블로그 작성 컨벤션](blog-authoring.md)을 따른다.

## Mermaid 그림

- 한 그림의 노드는 8개 이하로 둔다.
- 노드와 간선 라벨의 한 줄은 24자 이하로 쓴다. 넘으면 `<br/>`로 나누거나 그림을 쪼갠다.
- 방향이 `LR` 또는 `RL`이면 가장 긴 연결 체인은 3개 이하로 둔다. 그보다 긴 흐름은 `TB`로 쓴다.
- subgraph를 둘 이상 나열하는 그림은 `TB`로 쓴다. 이 항목은 검사하지 않으므로 가이드의 화면 검토에서 확인한다.

## 간격

- 간격은 `--space-1`~`--space-8`과 `--flow-paragraph`, `--flow-block`, `--flow-heading` 토큰만 쓴다. 글 머리와 본문 규칙에 px 리터럴을 새로 추가하지 않는다.
- 본문 요소의 간격 규칙은 `.prose :where(...)` 선택자로 쓰고 첫 요소의 위쪽 간격은 0으로 되돌린다.

## 커버 이미지

- 커버는 `viewBox="0 0 1200 630"`이다.
- 커버를 보여 주는 모든 면(상세 `.post-cover`, 목록 `.post-card-cover`)은 `--cover-aspect: 1200 / 630` 토큰 하나를 `aspect-ratio: var(--cover-aspect)`로 쓰고 `object-fit: contain`을 유지한다. 새 커버 표시 면을 추가하면 policy `covers.surfaces`에 먼저 등록한다.
- 이름에 `cover`가 들어간 CSS 규칙에는 `object-fit: cover`와 `object-fit: fill`을 쓰지 않는다. 커버는 자르거나 늘리지 않는다.
- 글의 커버 출처(front matter `coverImage`, 없으면 본문 첫 로컬 이미지)가 래스터나 SVG이면 가로세로 비율이 1.4 이상 2.4 이하여야 한다. 그 범위가 아닌 이미지는 `coverImage`로 `public/post-covers`의 SVG를 지정한다.
- 기존 글의 위반은 `site/scripts/blog-cover-baseline.json`이 허용한다. 새 항목을 추가하지 않고, 커버를 고치면 항목을 지운다. 지우지 않으면 `cover-baseline-stale`로 실패한다.
- SVG 그림은 모든 가장자리에서 10% 이상 떨어져 있어야 한다. 가장자리까지 채운 그림은 최상위 `<g transform="translate(x y) scale(s)">` 하나로 감싸 줄인다. 이 형태 밖의 `transform`은 검사할 수 없어 `cover-unsupported-structure`로 보고된다.

## 검사

```bash
pwsh -NoProfile -File site/scripts/Test-BlogPresentationConvention.ps1
```

통과하면 `[technical-blog-presentation-guard] OK posts=N covers=M`을 출력한다. 진단은 `technical-blog-presentation-*` 코드와 파일 이름만 출력하며, 코드의 의미는 하네스 [표시 품질 컨벤션](../../lib/Garden.Harness/src/markdown/docs/convention/technical-blog-presentation.md)을 따른다.

| 진단 | 의미와 조치 |
| --- | --- |
| `diagram-too-many-nodes` | 노드가 8개를 넘는다. 그림을 쪼갠다. |
| `diagram-label-too-long` | 한 줄 라벨이 24자를 넘는다. 줄이거나 `<br/>`로 나눈다. |
| `diagram-horizontal-chain-too-long` | `LR` 체인이 3개를 넘는다. `TB`로 바꾼다. |
| `cover-margin-insufficient` | 커버 그림이 가장자리에서 10% 안쪽이다. 그룹으로 감싸 줄인다. |
| `token-missing`, `rule-missing` | 스타일의 토큰이나 본문 규칙이 지워졌다. 복원한다. |
| `cover-surface-crop` | `cover`가 들어간 규칙이 `object-fit: cover`나 `fill`을 쓴다. `contain`으로 바꾼다. |
| `cover-surface-missing` | 등록된 커버 표시 면(`.post-card-cover` 등)의 규칙이 없다. 복원한다. |
| `cover-css-declaration-missing` | 커버 표시 면에 `object-fit: contain`이나 `aspect-ratio: var(--cover-aspect)`가 없다. 추가한다. |
| `cover-aspect-token-drift` | `--cover-aspect` 값이 policy와 다르다. 값을 되돌리거나 policy와 함께 바꾼다. |
| `cover-source-aspect-mismatch` | 글의 커버 출처 비율이 범위를 벗어난다. `coverImage`로 SVG 커버를 지정한다. |
| `cover-source-unreadable` | 커버 출처 파일이 없거나 형식을 읽을 수 없다. 경로나 파일을 고친다. |
| `cover-baseline-stale` | baseline 항목의 글이 이제 통과한다. 항목을 지운다. |

## 사람 검토 경계

여백이 충분해 보이는지, 그림 글자가 읽히는지는 이 검사가 판정하지 않는다. 가이드의 화면 검토 체크리스트를 localhost 화면에서 사람이 확인한다.
