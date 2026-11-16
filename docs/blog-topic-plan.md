# 블로그 주제 계획 (Orchid · Peony · Garden)

2026-11 git 히스토리 기준. 글 하나는 본문 4,000자(10분) 이하이며, 각 글은 질문 하나에 답하고 앞 글 없이도 읽힌다. 유형은 `concept`, `tutorial`, `incident`, `design` 중 하나다.

## A. Peony 저장소 분리

| # | 제목 후보 | 유형 | 질문 | 근거 |
| --- | --- | --- | --- | --- |
| 1 | 서비스 15개를 하루에 독립 저장소로 옮긴 기록 | design | 하루에 무엇을 옮기고 무엇이 남았나 | `blog/peony-monorepo-split-fifteen-services.md` (초안 작성됨) |
| 2 | 공유 계약을 서비스로 돌려보낸 과정 | design | 계약 타입은 누가 소유해야 하나 | Contract `shed ... contract folder` 7건, Product·User의 소유 커밋과 Revert |
| 3 | 사내 NuGet 피드 복원 실패를 막는 점검표 | tutorial | pack과 restore가 CI에서 깨지는 이유는 | `restore client packages from the hanul feed`, `create the empty local package source`, LICENSE·icon·README 누락 |

## B. Garden.Cluster GitOps 승격

| # | 제목 후보 | 유형 | 질문 | 근거 |
| --- | --- | --- | --- | --- |
| 4 | 서비스를 네 묶음으로 나눠 운영에 올린 이유 | design | 한 번에 올리지 않은 이유는 | `activate batch two~four staging/production controllers` |
| 5 | 운영 반영을 secret 준비 상태로 막는 방법 | design | 운영 롤아웃을 언제 멈추나 | `gate production rollout on secret readiness`, `keep counterparty production rollout unapproved` |
| 6 | staging은 tag, production은 digest로 고정한 이유 | design | 환경마다 이미지 기준을 달리하는 이유는 | `constrain staging image policy to tag`, `pin production images to verified digests` |
| 7 | 이미지 자동화가 멈췄을 때 쓰기 키를 확인하는 순서 | incident | 자동 갱신이 멈춘 원인은 | `restore ... automation write key`, `allow service image automation write keys` |
| 8 | RabbitMQ vhost 소유권을 지키며 설정을 옮긴 방법 | incident | 같은 이름의 리소스가 사라지지 않게 하려면 | Importer·Notifier `preserve staging RabbitMQ ... vhost`, Aspire `retire legacy ... writers` |
| 9 | Grafana 관리 토큰 재발급이 실패한 순서 | incident | 토큰 저장이 실패한 원인은 | `reissue Grafana managed token safely`, `use merge patch for Grafana token storage` |
| 10 | Keycloak 로그인 쿠키 흐름을 복구한 기록 | incident | 로그인이 끊긴 원인은 | `restore broker cookie flow` |

## C. Orchid

| # | 제목 후보 | 유형 | 질문 | 근거 |
| --- | --- | --- | --- | --- |
| 11 | 제품 저장소를 분리하고 /orchid 경로로 서빙한 방법 | design | 한 도메인에 제품을 얹는 방법은 | Orchid.* 초기 이관 (11-11), `switch to /orchid subpath routing` |
| 12 | Web·Desktop·Mobile이 같은 화면을 쓰는 방법 | design | 세 플랫폼의 UI를 어떻게 맞추나 | `Light/Dark theme`, `align GardenTopAppBar`, 테마 토큰화 |
| 13 | 데스크톱 앱에 Keycloak 로그인을 붙인 방법 | tutorial | 브라우저 로그인 결과를 앱이 받는 방법은 | `loopback PKCE OIDC auth`, `pin Keycloak OIDC loopback redirect URIs`, `recover from closed login browser window` |
| 14 | Windows 앱이 흐릿하게 보일 때 확인할 설정 | tutorial | DPI 선언이 없으면 무엇이 달라지나 | `declare Per-Monitor V2 DPI awareness`, Garden `warn when a Windows app runs DPI-unaware` |
| 15 | Microsoft Store 제출을 CI로 자동화한 방법 | tutorial | Partner Center 제출을 어떻게 연결하나 | `bind Partner Center identity`, `setup-msstore-cli`, `DevCenter submission` |

## D. Garden.Cli · Harness

| # | 제목 후보 | 유형 | 질문 | 근거 |
| --- | --- | --- | --- | --- |
| 16 | 인프라 변경을 plan과 apply로 나눈 방법 | design | 실행 전 변경 내용을 어떻게 확인하나 | `shared plan/apply change contract`, `redact inventory render failures` |
| 17 | 사람과 AI가 같은 저장소를 고칠 때 쓰는 가드 | design | 규칙을 어떻게 코드로 강제하나 | Harness `guard` 커밋, Notion Archive 자동 게시 |

## 작성 규칙 메모

- 제목은 결과 한 문장으로 쓰고 `: 꼬리표`는 달지 않는다([제목 컨벤션](convention/blog-title.md)). 제품·기술 맥락은 `tags`와 첫 요약이 맡는다.
- 커버는 글의 핵심 대비를 설명하는 SVG를 `coverImage`로 지정한다. 기본 이미지는 쓰지 않는다.
- 이유나 동기가 커밋에 없으면 지어 쓰지 않고 관측 한계로 적는다.
- 시각·건수는 `git log`로 다시 확인한다.
- 7~10번은 secret·토큰·내부 식별자를 쓰지 않고 키 이름만 일반화한다.
- 1번 초안을 쓴 뒤 분량 지표: 본문 약 1,700자(상한의 42%).
