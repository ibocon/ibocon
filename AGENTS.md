# ibocon

## 블로그 글 작성

- 글을 새로 쓰거나 실질 개정할 때는 `author-technical-blog-post` 스킬로 시작하고 `docs/convention/blog-authoring.md`, `blog-title.md`, `blog-presentation.md`를 모두 적용한다. 기존 이관 글을 실질 개정하면 `authoringVersion: 1`로 opt-in한다.
- 본문, 제목, 목록, 표, 각주는 한다체(문어체, `-다`)로 쓴다. 존댓말(`-합니다`, `-해요`)은 쓰지 않는다. 어조 기준 글은 `blog/kubernetes-alertmanager-postfix-open-relay.md`다.
- 용어는 `site/src/data/glossary.json`의 표준 표기만 쓰고 글마다 첫 등장을 `/glossary/#id`로 연결한다(`docs/convention/blog-terminology.md`).
- 저장한 뒤 `site/scripts`의 `Test-BlogAuthoringConvention.ps1`, `Test-BlogTerminology.ps1`, `Test-BlogTitleConvention.ps1`, `Test-BlogPresentationConvention.ps1`을 실행해 exit 0을 확인한다.

이 파일의 하단 managed block은 Garden Harness bootstrap이 관리한다.

<!-- HARNESS:START -->
- 시작: `lib/Garden.Harness/src/agents/AGENT_CONTEXT.md`
- 라우터: `lib/Garden.Harness/src/agents/skills/orchestrate-workflows/SKILL.md`
- 워크플로우: `lib/Garden.Harness/src/core/docs/harness-workflow.md`
- 검증: `lib/Garden.Harness/src/agents/skills/verify-completion/SKILL.md`
<!-- HARNESS:END -->
