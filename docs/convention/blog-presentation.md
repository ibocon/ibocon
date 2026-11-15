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

- 커버는 `viewBox="0 0 1200 630"`이고 CSS는 `object-fit: contain`과 `aspect-ratio: 1200 / 630`을 유지한다.
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

## 사람 검토 경계

여백이 충분해 보이는지, 그림 글자가 읽히는지는 이 검사가 판정하지 않는다. 가이드의 화면 검토 체크리스트를 localhost 화면에서 사람이 확인한다.
