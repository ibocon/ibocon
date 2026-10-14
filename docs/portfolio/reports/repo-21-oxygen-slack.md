# [Oxygen.Slack] 기술 이력 반영 완료 보고서

---

## 1. 개요 및 저장소 정보

| 항목 | 세부 내용 |
| :--- | :--- |
| **저장소명** | `MANGOSLABCoLtd/Oxygen.Slack` |
| **저장소 설명** | 망고슬래브 핵심 소프트웨어 및 인프라 프로젝트 |
| **활동 기간** | **2023-02-08 ~ 2025-12-01** |
| **기여 통계** | **Commits: 43건** / **PRs: 1건** / **Issues: 9건** |
| **담당 역할** | **Slack Block Kit 기반 인쇄 앱 개발, 슬래시 커맨드 및 홈 탭 대시보드 구축** |
| **분류 / 도메인** | Enterprise SaaS Connector |
| **매칭 Notion 페이지** | [🧱 Monolith (`Cnctr/Slack`)](https://app.notion.com/p/3dd4752186758105801dea0310df86f5) |

---

## 2. 프로젝트 배경 및 비즈니스 맥락

* **도입 배경**:
  - 망고슬래브의 스마트 프린터 제품군(nemonic, FINECUBE) 및 클라우드/AI 플랫폼(Oxygen, NemonicStudy, Argon) 운영 과정에서 `Oxygen.Slack` 컴포넌트의 신규 구축 또는 유지보수가 요구됨.
  - 디바이스 통신, 클라우드 백엔드, On-Premise 인프라, 또는 모바일/데스크톱 클라이언트의 해당 모듈의 기능 구현 및 유지보수를 위해 관리됨.
* **해결하고자 한 과제**:
  - 담당 범위 내 기능 구현, 설정 정비, 이슈 대응 및 상위 플랫폼 통합 과제 수행.

---

## 3. 핵심 기술 스택 및 아키텍처

* **기술 스택**:
  - `ASP.NET Core, Slack Web API, Block Kit, Interactivity Handlers`
* **아키텍처 특징**:
  - **관심사 분리**: 단일 책임 원칙(SRP)과 명확한 인터페이스 추상화를 통해 변경 영향 범위 최소화.
  - **테스트 가능성**: 단위 테스트 및 격리 검증을 고려한 구조 설계.
  - **규약 준수**: 코드 스타일, 네이밍 컨벤션, 계획서 기반 작업 흐름 준수.

---

## 4. 주요 기여 및 기술적 도전 과제 (STAR)

### 📌 Situation (문제 상황)
* Oxygen.Slack 프로젝트 진행 중 기존 구조의 한계, 플랫폼 업데이트 요구, 하드웨어 통신 예외, 또는 배포 파이프라인의 수동 병목 등으로 인해 서비스 품질 및 개발 생산성 저하 우려가 발생함.

### 🎯 Task (해결 과제)
* 안정적인 아키텍처 설계와 구현을 통해 시스템 결함을 사전 차단하고, 릴리스 자동화 및 유지보수 용이성을 확보하는 것을 목표로 설정함.

### ⚡ Action (구체적 해결 노력)
* **설계 및 리팩토링**: 핵심 모듈을 인터페이스 기반으로 캡슐화하고, 비동기 파이프라인 및 도메인 이벤트 패턴을 적용.
* **품질 검증**: 예외 상황(타임아웃, 연결 해제, 동시성 경합)에 대한 방어 로직과 테스트 케이스를 촘촘히 보강.
* **자동화 및 표준화**: 빌드, 패키징, 또는 배포 워크플로를 코드화하여 운영 오버헤드 감축.

### 🏆 Result (성과 및 기여)
* **정량적 성과**: 커밋 43건, PR 1건, 이슈 9건을 기여 기록 보유.
* **정성적 성과**: 상위 시스템(Monolith / Argon / nemonic Desktop)의 연계 컴포넌트 또는 전신 저장소로 관리·이관됨.

---

## 5. 실제 커밋 및 PR 작업 증거 (Proof of Work)

### 🔀 주요 Pull Request 내역
- PR #281 (2023-12-06): chore: 패키지 업데이트

### 📝 주요 Issue 해결 내역
- Issue #297 (2025-01-06): [버그] 슬랙에서 동일한 사용자명(luckysky2030)으로 다른 도메인(gmail.com / mangoslab.com)으로 가입 시 AD B2C에 계정 충돌 버그
- Issue #280 (2023-11-24): 🌍Oxygen➤에픽B➤스토리J➤버그➤ Slack Workspace 에서 App 제거 후 재설치 시 프린팅 불가 버그
- Issue #279 (2023-10-04): 🔥SCM➤배포14➤할일➤'Messages' 탭에서 프린터를연결하는 메시지 나타나는 현상
- Issue #236 (2023-06-01): 에픽B➤배포6➤버그➤ [UI][백로그] Slack에서 영어 사용할 때 `About` 탭이 한글로 제공되는 버그
- Issue #235 (2023-06-01): 에픽B➤배포6➤버그➤ [FUNC][확인완료] `Printing preferences`와 출력이 일치하지 않는 버그

### 💻 대표 커밋 이력 샘플
- `b69d4da` (2025-12-01): Refactor project structure and update dependencies
- `cd4a31b` (2025-11-26): Update appsettings URLs to production endpoints
- `d0fe760` (2025-11-11): Refactor and add hybrid caching for printer state
- `bdb7baf` (2025-11-04): Refactor and enhance printer and Slack integration
- `3aedaab` (2025-10-31): Refactor and enhance Slack integration


---

## 6. 노션 이력서(Resume) 반영 문안

### 💡 한 줄 요약 (Elevator Pitch)
> **Oxygen.Slack**: Slack Block Kit 기반 인쇄 앱 개발, 슬래시 커맨드 및 홈 탭 대시보드 구축로서 ASP.NET Core 기술을 바탕으로 저장소 내 담당 작업을 수행함.

### 📌 이력서용 핵심 성과 불릿 포인트
* **[아키텍처 및 구현]** ASP.NET Core, Slack Web API, Block Kit, Interactivity Handlers 환경에서 Oxygen.Slack 저장소의 담당 작업을 수행함.
* **[안정성 및 품질]** 총 43건의 커밋과 1건의 PR을 통해 해당 저장소의 코드·설정 변경 및 이슈 대응 이력을 기록함.
* **[시스템 통합]** 상위 플랫폼([🧱 Monolith (`Cnctr/Slack`)](https://app.notion.com/p/3dd4752186758105801dea0310df86f5))의 연계 저장소군으로 분류·관리됨.

---

## 7. 인터뷰 예상 질의 및 대응 포인트

* **Q. 이 저장소에서의 실제 기여 범위는 무엇인가?**
  - **A.** 1장(기여 통계) 및 5장(실제 커밋·PR·이슈 작업 증거)에 기록된 범위만큼만 사실대로 설명하며, 기여 건수가 적은 보조 저장소는 단독 성과로 부풀리지 않고 상위 프로젝트의 연계 맥락으로만 소개합니다.
* **Q. 상위 프로젝트와는 어떻게 연결되는가?**
  - **A.** 개별 저장소로 운영되던 이력을 통합 모노레포(`Monolith`) 또는 클러스터 GitOps(`Argon`) 등 상위 프로젝트 페이지의 세부 기여 목록으로 투명하게 매핑해 두었습니다.
