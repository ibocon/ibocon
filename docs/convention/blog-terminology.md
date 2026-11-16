# 블로그 용어 컨벤션

## 목적

같은 개념을 글마다 다르게 부르지 않게 하고, 독자가 용어의 기준 정의를 글 밖에서 확인할 수 있게 한다. 용어의 표준 표기와 정의는 용어집이 소유하고, 글은 그 표기만 쓴다.

## 용어집

- 표준 표기, 정의, 금지 표기는 `site/src/data/glossary.json`이 소유한다. 용어집 페이지(`/glossary/`)와 `site/scripts/Test-BlogTerminology.ps1`이 같은 파일을 읽는다.
- 레이어 이름은 `영문 이름 + 레이어` 형식이다. 예: `Domain 레이어`, `Application 레이어`. `어플리케이션 레이어`, `어플리케이션 Layer`, `App 레이어`는 쓰지 않는다.
- 새 용어는 글을 쓰기 전에 `glossary.json`에 등록한다. 표준 표기 하나와 알려진 변종을 `forbidden`에 함께 쓴다. 정의는 한다체로 쓴다.
- `id`는 소문자 kebab-case이고 용어집 페이지의 앵커가 된다. 같은 표기가 두 용어의 `term`이나 `forbidden`에 겹치면 안 된다.

## 본문 규칙

- `authoringVersion: 1` 글은 등록된 용어를 표준 표기로만 쓴다.
- 글마다 용어의 첫 등장을 `[Application 레이어](/glossary/#application-layer)`처럼 용어집 앵커로 연결한다. 제목 줄, 코드, 다른 주소로 가는 링크 안의 등장은 첫 등장으로 세지 않는다.
- 용어집에 등록된 용어는 각주로 다시 설명하지 않는다. 등록되지 않은 보조 용어만 [블로그 작성 컨벤션](blog-authoring.md)의 규칙에 따라 각주로 설명한다.
- 코드 블록과 인라인 코드 안의 표기는 검사하지 않는다. 변종을 글에서 설명해야 하면 인라인 코드로 쓴다.
- 기존 이관 글은 소급 검사하지 않는다. 실질 개정하면서 `authoringVersion: 1`을 선언할 때 적용한다.

## 검사

```bash
pwsh -NoProfile -File site/scripts/Test-BlogTerminology.ps1
```

| 코드 | 의미와 조치 |
| --- | --- |
| `blog-terminology-variant-term` | 금지 표기를 썼다. 표준 표기로 바꾼다. |
| `blog-terminology-case-variant` | 대소문자나 띄어쓰기만 다르다. 표준 표기로 맞춘다. |
| `blog-terminology-link-missing` | 용어의 첫 등장이 용어집 링크가 아니다. 앵커로 연결한다. |
| `blog-terminology-link-target-unknown` | 용어집에 없는 앵커로 연결했다. 앵커나 용어집을 고친다. |
| `blog-terminology-glossary-invalid` | 용어집 데이터가 규칙을 어겼다. id 중복이나 표기 충돌을 고친다. |

진단은 `파일명:줄 [용어 id]` 형식이며 줄은 본문 첫 줄을 1로 센다. 이 검사는 표기와 링크의 존재만 판정하며, 정의가 정확한지는 사람 리뷰에서 확인한다.
