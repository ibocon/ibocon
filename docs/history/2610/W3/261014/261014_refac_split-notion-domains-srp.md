# ✅ 노션 이력서 9대 단일 책임 도메인(SRP) 원자적 분할 리팩토링

## 계획 관계

> **관계 스키마**: `1`
> **계획 ID**: `ibocon:261014_refac_split-notion-domains-srp`
> **출처 판정**: `연결`
> **출처 판정 근거**: 노션 이력서 5대 복합 도메인을 단일 책임 원칙(SRP)에 따라 9개 원자적 직무 도메인으로 세분화하고 BLE 디바이스 연동을 시스템 프로그래밍으로 재편하는 후속 리팩토링

| 관계 | 대상 계획 ID | 조건 | 근거·인수 범위 |
| --- | --- | --- | --- |
| 후속 | `ibocon:261014_refac_relocate-non-notion-portfolio-docs` | 해당 없음 | `resume/` 마스터 문서와 `docs/portfolio/strategy/` 설계·컨벤션 문서의 9대 단일 책임 도메인 체계 전환 |

<!-- plan-relations-summary:start -->
> 자동 생성 관계 요약. 원본은 위 관계 표입니다.

| 구분 | 계획·조건 |
| --- | --- |
| 최초 계획 | [✅ 노션 비배포 포트폴리오 문서 및 저장소 보고서 분리 이전 계획](<261014_refac_relocate-non-notion-portfolio-docs.md>) `ibocon:261014_refac_relocate-non-notion-portfolio-docs` |
| 직접 출처 | [✅ 노션 비배포 포트폴리오 문서 및 저장소 보고서 분리 이전 계획](<261014_refac_relocate-non-notion-portfolio-docs.md>) `ibocon:261014_refac_relocate-non-notion-portfolio-docs` |
| 직접 후속 | [✅ 소프트웨어 아키텍처 도메인의 설계 이론 중심 재편 및 Garden 하위 페이지 도메인별 재배치](<../261015/261015_refac_restructure-architecture-domain-and-garden-subpages.md>) `ibocon:261015_refac_restructure-architecture-domain-and-garden-subpages` |
| 계보 경로 | [✅ 노션 비배포 포트폴리오 문서 및 저장소 보고서 분리 이전 계획](<261014_refac_relocate-non-notion-portfolio-docs.md>) `ibocon:261014_refac_relocate-non-notion-portfolio-docs` → [✅ 노션 이력서 9대 단일 책임 도메인(SRP) 원자적 분할 리팩토링](<261014_refac_split-notion-domains-srp.md>) `ibocon:261014_refac_split-notion-domains-srp` |
| 후속 | [✅ 노션 비배포 포트폴리오 문서 및 저장소 보고서 분리 이전 계획](<261014_refac_relocate-non-notion-portfolio-docs.md>) `ibocon:261014_refac_relocate-non-notion-portfolio-docs` — 해당 없음 |
| 착수 조건 | 가능 |
<!-- plan-relations-summary:end -->

## 결정이 필요한 사항

1. **복합 도메인의 원자적 분리 구조 (5개 → 9개 단일 책임 도메인)** — 9대 단일 책임 도메인으로 전면 분할 (권장)
- 근거: 한 폴더 제목에 두 가지 이상의 직무/기술 영역(`백엔드 & 아키텍처`, `DevOps & 인프라`, `DevEx & 웹 디자인 시스템`, `Windows 데스크톱 & 시스템 프로그래밍`, `모바일 & BLE`)이 결합되어 있으면 관심사가 혼합되고 채용 담당자의 직무별 타깃 열람 정확도가 떨어진다.
- 대안: 상위 5개 폴더를 유지하고 내부 섹션만 구분. 사이드바 1차 네비게이션에서 여전히 두 영역이 묶여 보여 단일 책임 원칙(SRP)을 위배한다.

2. **BLE 디바이스 연동의 도메인 귀속 위치** — `08. 시스템 프로그래밍 & 하드웨어 연동 (Win32, USB, BLE)`으로 통합하고 `09. 모바일 애플리케이션`은 순수 모바일 앱 단독 도메인으로 분리 (권장)
- 근거: BLE GATT 프로토콜 제어, 패킷 청크 스트리밍, WinUSB/P-Invoke 드라이버는 하드웨어 통신 및 시스템 프로그래밍 영역의 핵심 역량이므로 시스템 프로그래밍 도메인에서 통합 서술하는 것이 기술적 응집도에 부합한다.
- 대안: BLE를 모바일 도메인에 잔류시킴. 모바일 UI/라이프사이클 역량과 저수준 하드웨어 프로토콜 제어 역량이 혼재된다.

## 배경

- **현재 문제점**:
  1. `01. .NET 백엔드 & 분산 아키텍처`: 서비스 API/데이터 처리 구현(백엔드)과 모듈러 모노레포/CQRS/도메인 모델링(소프트웨어 아키텍처)이 하나의 폴더로 묶여 있다.
  2. `02. DevOps & 클라우드 인프라`: 배포 자동화/GitOps 파이프라인(DevOps)과 베어메탈 K8s/Proxmox/Rook-Ceph 스토리지/네트워크 제어면(클라우드 인프라)이 결합되어 있다.
  3. `03. 개발자 경험(DevEx) & 웹 디자인 시스템`: AI 코딩 에이전트 하네스·정적 애널라이저(DevEx)와 Penpot 토큰·Blazor UI 컴포넌트 라이브러리(웹 디자인 시스템)라는 서로 다른 전문 영역이 한 폴더에 혼재되어 있다.
  4. `04. Windows 데스크톱 & 시스템 프로그래밍`: WPF/WinForms 데스크톱 클라이언트 개발과 Win32/USB/BLE 저수준 하드웨어 프로토콜 제어가 결합되어 있다.
  5. `05. 모바일 & BLE 디바이스 연동`: 모바일 앱 개발과 BLE 하드웨어 제어 프로토콜이 묶여 있어, BLE 디바이스 연동을 시스템 프로그래밍으로 이관하고 모바일은 순수 모바일 단독 도메인으로 정리할 필요가 있다.
- **리팩토링 방향**:
  1. 한 도메인 폴더가 오직 하나의 직무 책임만 갖도록 **9대 단일 책임 도메인(01 백엔드, 02 아키텍처, 03 DevOps, 04 클라우드 인프라, 05 개발자 경험, 06 웹 디자인 시스템, 07 Windows 데스크톱, 08 시스템 프로그래밍 & BLE/USB 연동, 09 모바일)**으로 쪼갠다.
  2. 컨벤션 문서(`convention-notion-resume-structure.md`), 아키텍처 설계서(`plan-strategy-05-notion-domain-hierarchy-architecture.md`), 마스터 이력서(`resume-yegun-kim.md`), 원격 Notion 페이지 및 검증 스크립트(`Test-NotionResumeHierarchy.ps1`)를 9대 도메인 체계로 일괄 동기화한다.

## 변경 범위

```mermaid
graph LR
    subgraph 변경 전
        A[5대 복합 결합 도메인 ❌]
    end
    subgraph 변경 후
        B[9대 단일 책임 원자적 도메인 ✅]
    end
    A -->|SRP 도메인 분할 및 BLE 시스템 프로그래밍 편입| B
    style A fill:#c92a2a,stroke:#a51111,color:#fff
    style B fill:#2b8a3e,stroke:#1b7a2e,color:#fff
```

| 레이어 | 파일 | 변경 내용 |
| --- | --- | --- |
| Strategy | `docs/portfolio/strategy/convention-notion-resume-structure.md` | 도메인 단일 책임 분할(SRP) 및 BLE 시스템 프로그래밍 귀속 규칙 추가 |
| Strategy | `docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md` | 5대 복합 도메인을 9대 단일 책임 도메인 트리 및 다이어그램으로 개편 |
| Resume SoT | `resume/resume-yegun-kim.md` | 주요 기술 영역 요약표 및 도메인 허브 페이지 링크를 9대 단일 책임 도메인으로 갱신 |
| Resume Index | `resume/README.md` | 9대 직무 도메인 분리 체계 기준으로 색인 테이블 설명 갱신 |

## 단계별 수정 계획

### ✅ Step 1: 노션 이력서 컨벤션 문서에 도메인 단일 책임(SRP) 규칙 추가

**파일**: `docs/portfolio/strategy/convention-notion-resume-structure.md`

AS-IS:

```markdown
<a id="domain-first-hierarchy"></a>
### 1. 최상위 폴더 도메인 중심 계층화 (Domain-First Hierarchy)

최상위 폴더는 채용 시장에서 통용되는 기술 도메인 및 직무 전문성 명칭으로만 구성해야 한다.

- ✅ **MUST** 최상위 폴더는 '백엔드 서비스 플랫폼', '클러스터 인프라 & GitOps', '디자인 시스템 & 웹 프론트엔드' 등 채용 공고(JD)와 직결되는 기술 도메인 명칭으로 작성한다.
- ⛔ **MUST NOT** 최상위 폴더 자체를 사내 프로젝트명(예: `Monolith`, `Argon`, `Peony`, `Lithium`)으로 구성한다.
- ⛔ **MUST NOT** 최상위 폴더를 공급 주체(예: '회사 프로젝트', '개인 프로젝트', '자체 플랫폼') 기준으로 양분한다.
```

TO-BE:

```markdown
<a id="domain-first-hierarchy"></a>
### 1. 최상위 폴더 도메인 중심 계층화 및 단일 책임 분할 (Domain-First & Single Responsibility)

최상위 폴더는 채용 시장에서 통용되는 기술 도메인 명칭으로 구성하되, 두 가지 이상의 이질적 직무 영역을 하나의 폴더에 결합하지 않고 단일 책임(SRP) 단위로 분리해야 한다.

- ✅ **MUST** 최상위 폴더는 백엔드, 아키텍처, DevOps, 클라우드 인프라, 개발자 경험(DevEx), 웹 디자인 시스템, Windows 데스크톱, 시스템 프로그래밍, 모바일 각각을 독립된 단일 도메인 폴더로 분리한다.
- ✅ **MUST** BLE(Bluetooth LE) 및 USB 하드웨어 디바이스 연동은 모바일 도메인이 아닌 '시스템 프로그래밍' 도메인에 포함하고, 모바일 도메인은 모바일 애플리케이션 단독으로 구성한다.
- ⛔ **MUST NOT** 하나의 최상위 폴더에 두 개 이상의 직무 영역(예: `백엔드 & 아키텍처`, `DevOps & 인프라`, `DevEx & 웹 디자인 시스템`, `데스크톱 & 시스템 프로그래밍`, `모바일 & BLE`)을 묶어서 표기한다.
- ⛔ **MUST NOT** 최상위 폴더 자체를 사내 프로젝트명(예: `Monolith`, `Argon`, `Peony`, `Lithium`)으로 구성한다.
- ⛔ **MUST NOT** 최상위 폴더를 공급 주체(예: '회사 프로젝트', '개인 프로젝트', '자체 플랫폼') 기준으로 양분한다.
```

### ✅ Step 2: 도메인 계층 구조 설계서를 9대 단일 책임 도메인 모델로 업데이트

**파일**: `docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md`

AS-IS:

```markdown
├── 📁 01. .NET 백엔드 & 분산 아키텍처 (C#, Clean Architecture, CQRS)
│   ├── 📄 [백엔드 · 모노레포] .NET 9 서비스 통합 & YARP API GW (Monolith)
│   ├── 📄 [분산 메시징] RabbitMQ & Outbox 패턴 가계부 서비스 (Peony Backend)
│   └── 📄 [AI 파이프라인] 비동기 잡 큐 & OCR/요약 마이크로서비스 (NemonicStudy)
│
├── 📁 02. DevOps & 클라우드 인프라 (K8s, GitOps, On-Premise, Ceph)
│   ├── 📄 [K8s GitOps] 온프레미스 듀얼 사이트 K8s & Active-Standby DR (Argon)
│   └── 📄 [클러스터 GitOps] 하이브리드 K8s(Proxmox·AKS) 클러스터 구성 (Garden.Cluster)
│
├── 📁 03. 개발자 경험(DevEx) & 웹 디자인 시스템 (Penpot, Harness, CI/CD)
│   ├── 📄 [디자인 시스템] Penpot 토큰 동기화 Razor 웹 컴포넌트 (Garden.Razor)
│   └── 📄 [개발 도구 · 하네스] Roslyn 정적 애널라이저 & AI 에이전트 하네스 (Garden.Harness)
│
├── 📁 04. Windows 데스크톱 & 시스템 프로그래밍 (WPF, Win32, 하드웨어 제어)
│   ├── 📄 [데스크톱 클라이언트] WYSIWYG 인쇄 엔진 & .NET 9 현대화 (nemonic)
│   └── 📄 [디바이스 드라이버] 저수준 USB/Bluetooth 통신 프로토콜 SDK (Mango)
│
└── 📁 05. 모바일 & BLE 디바이스 연동 (Android, iOS, .NET MAUI, BLE)
    ├── 📄 [모바일 클라이언트] .NET MAUI Blazor Hybrid 가계부 앱 (Peony Mobile)
    └── 📄 [하드웨어 연동 앱] FINECUBE 컬러 라벨 앱 & BLE 통신 경합 해소 (Lithium)
```

TO-BE:

```markdown
├── 📁 01. .NET 백엔드 엔지니어링 (ASP.NET Core, YARP, PostgreSQL, Redis)
│   ├── 📄 [백엔드 서비스] .NET 9 서비스 통합 & YARP API GW (Monolith)
│   └── 📄 [AI 백엔드] 비동기 잡 큐 & OCR/요약 마이크로서비스 (NemonicStudy)
│
├── 📁 02. 소프트웨어 아키텍처 (Clean Architecture, DDD, CQRS, VSA)
│   ├── 📄 [분산 아키텍처] RabbitMQ & Outbox 패턴 가계부 서비스 (Peony)
│   └── 📄 [공통 아키텍처 계층] 자체 Mediator · Result 패턴 · 도메인 이벤트 기반 (Garden.Share)
│
├── 📁 03. DevOps 엔지니어링 (Flux GitOps, CI/CD, Container Release)
│   ├── 📄 [GitOps 배포] Flux v2 멀티 클러스터 배포 & Active-Standby 전환 계약 (Argon)
│   └── 📄 [CI/CD 파이프라인] GitHub Actions 컨테이너 퍼블리시 & 자체 호스팅 러너 (Pipeline)
│
├── 📁 04. 클라우드 및 온프레미스 인프라 (Kubernetes, Proxmox, Rook-Ceph, OpenBao)
│   ├── 📄 [클러스터 인프라] Proxmox VE & Azure AKS 하이브리드 클러스터 운영 (Garden.Cluster)
│   └── 📄 [데이터 · 보안 제어면] Rook-Ceph 스토리지 · CloudNativePG · OpenBao 시크릿 (Infra)
│
├── 📁 05. 개발자 경험 (DevEx, AI Agent Harness, Roslyn Analyzer)
│   ├── 📄 [AI 에이전트 하네스] 4대 코딩 에이전트 공통 규약 & 정적 가드 (Garden.Harness)
│   └── 📄 [정적 분석기] Roslyn 커스텀 애널라이저 7종 & 코드픽스 (Garden.Analyzers)
│
├── 📁 06. 웹 디자인 시스템 (Penpot, Blazor, Material 3, SCSS Tokens)
│   ├── 📄 [디자인 시스템] Penpot 토큰 동기화 Material 3 Blazor 컴포넌트 44종 (Garden.Razor)
│   └── 📄 [컴포넌트 갤러리] Blazor WebAssembly 인터랙티브 UI 갤러리 (Garden.Razor.Gallery)
│
├── 📁 07. Windows 데스크톱 애플리케이션 (.NET 9, WinForms, WPF, MVVM)
│   └── 📄 [데스크톱 클라이언트] WYSIWYG 인쇄 엔진 & .NET 9 현대화 (nemonic Desktop)
│
├── 📁 08. 시스템 프로그래밍 (Win32, GDI+, USB, BLE 디바이스 연동)
│   ├── 📄 [USB · BLE 드라이버] WinUSB · WebUSB · 5계층 BLE 프로토콜 추상화 SDK (Mango & Garden)
│   └── 📄 [BLE 디바이스 제어] 프린터 상태 폴링 경합 해소 & GDI DC 핸들 제어 (Device Interop)
│
└── 📁 09. 모바일 애플리케이션 (.NET MAUI, Xamarin.Forms, Android, iOS)
    ├── 📄 [모바일 가계부 앱] .NET MAUI Blazor Hybrid 크로스플랫폼 클라이언트 (Peony Mobile)
    └── 📄 [모바일 라벨러 앱] FINECUBE Android · iOS 앱 유지보수 및 targetSdk 34 상향 (Lithium)
```

### ✅ Step 3: 마스터 이력서(`resume/resume-yegun-kim.md`) 및 Notion 루트 페이지 9대 도메인 갱신

**파일**: `resume/resume-yegun-kim.md`

AS-IS:

```markdown
## 📂 5대 직무 도메인별 상세 포트폴리오 (Domain Hub)
<span color="gray">각 도메인 폴더를 클릭하시면 해당 직무 영역의 아키텍처 철학과 하위 프로젝트별 상세 기술서를 확인하실 수 있습니다.</span>
<page url="https://app.notion.com/p/3f9475218675816e9d0bf75ee6a51ba6">01. .NET 백엔드 & 분산 아키텍처 (C#, Clean Architecture, CQRS)</page>
<page url="https://app.notion.com/p/3f9475218675819baf65f8976281b85d">02. DevOps & 클라우드 인프라 (K8s, GitOps, On-Premise, Ceph)</page>
<page url="https://app.notion.com/p/3f947521867581e69559d6fbaa56760f">03. 개발자 경험(DevEx) & 웹 디자인 시스템 (Penpot, Harness, CI/CD)</page>
<page url="https://app.notion.com/p/3f94752186758126a28cd2ecf057ead7">04. Windows 데스크톱 & 시스템 프로그래밍 (WPF, Win32, 하드웨어 제어)</page>
<page url="https://app.notion.com/p/3f947521867581bbbc88ec8bf5a9dff9">05. 모바일 & BLE 디바이스 연동 (Android, iOS, .NET MAUI, BLE)</page>
```

TO-BE:

```markdown
## 📂 9대 직무 도메인별 상세 포트폴리오 (Domain Hub)
<span color="gray">각 도메인 폴더를 클릭하시면 해당 기술 영역의 상세 작업 내역을 확인하실 수 있습니다.</span>
<page url="https://app.notion.com/p/3f9475218675816e9d0bf75ee6a51ba6">01. .NET 백엔드 엔지니어링 (C#, YARP, PostgreSQL)</page>
<page url="https://app.notion.com/p/3fa475218675817b914ac9fa6ff9a9f4">02. 소프트웨어 아키텍처 (Clean Architecture, DDD, CQRS)</page>
<page url="https://app.notion.com/p/3f9475218675819baf65f8976281b85d">03. DevOps 엔지니어링 (Flux GitOps, CI/CD, Container)</page>
<page url="https://app.notion.com/p/3fa475218675819995bfeab3391da08b">04. 클라우드 및 온프레미스 인프라 (Kubernetes, Proxmox, Rook-Ceph)</page>
<page url="https://app.notion.com/p/3f947521867581e69559d6fbaa56760f">05. 개발자 경험 (DevEx, AI Agent Harness, Roslyn)</page>
<page url="https://app.notion.com/p/3fa47521867581be8577cd764904163d">06. 웹 디자인 시스템 (Penpot, Blazor, Material 3)</page>
<page url="https://app.notion.com/p/3f94752186758126a28cd2ecf057ead7">07. Windows 데스크톱 애플리케이션 (.NET 9, WinForms, WPF)</page>
<page url="https://app.notion.com/p/3fa47521867581968228f136738abaca">08. 시스템 프로그래밍 (Win32, GDI+, USB, BLE 디바이스 연동)</page>
<page url="https://app.notion.com/p/3f947521867581bbbc88ec8bf5a9dff9">09. 모바일 애플리케이션 (.NET MAUI, Xamarin.Forms, Android, iOS)</page>
```

### ✅ Step 4: 총괄 색인(`resume/README.md`) 9대 단일 책임 도메인 설명 갱신

**파일**: `resume/README.md`

AS-IS:

```markdown
| **전략 5 — 노션 이력서 도메인별 계층 구조 (폴더 트리 모델) 설계서** | [`plan-strategy-05-notion-domain-hierarchy-architecture.md`](../docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md) | 사내 프로젝트명 중심 구조를 5대 직무 전문성 도메인(백엔드/인프라/DevEx·디자인시스템/데스크톱/모바일) 폴더 트리로 개편하는 아키텍처 설계서 | **완료 (`✅`)** |
```

TO-BE:

```markdown
| **전략 5 — 노션 이력서 도메인별 계층 구조 (폴더 트리 모델) 설계서** | [`plan-strategy-05-notion-domain-hierarchy-architecture.md`](../docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md) | 복합 도메인을 9대 단일 책임 도메인(백엔드/아키텍처/DevOps/인프라/DevEx/디자인시스템/데스크톱/시스템프로그래밍·BLE/모바일)으로 세분화한 아키텍처 설계서 | **완료 (`✅`)** |
```

## 테스트 계획

> 위치: `docs/portfolio/strategy/convention-notion-resume-structure.md`
> 프레임워크: PowerShell Guard (`Test-MarkdownDocumentConventionGuard.ps1`)
> 패턴: Given/When/Then 정적 구조 및 마크다운 규약 검증

### ✅ 테스트용 Stub 정의

`resume/resume-yegun-kim.md`

```markdown
## 📂 9대 직무 도메인별 상세 포트폴리오 (Domain Hub)
<page url="https://app.notion.com/p/...">01. .NET 백엔드 엔지니어링 (C#, YARP, PostgreSQL)</page>
```

### ✅ 테스트: `resume/README.md`

`docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md`

```powershell
# Given: 9대 단일 책임 도메인으로 분리된 resume/ 및 docs/portfolio/ 마크다운 문서
# When: 마크다운 문서 규약 가드 및 노션 계층 검증 실행
pwsh -NoProfile -ExecutionPolicy Bypass -File lib/Garden.Harness/src/markdown/guards/Test-MarkdownDocumentConventionGuard.ps1 -Path docs/portfolio
# Then: 위반 0건(EXIT 0) 반환
```

### 테스트 요약

| 테스트 클래스 | 검증 대상 | 테스트 수 |
| --- | --- | ---: |
| `Test-MarkdownDocumentConventionGuard.ps1` | 9대 단일 책임 도메인 마크다운 파일명 및 헤딩 컨벤션 | 4 |
| **합계** | | **4** |

### 테스트 결과

| 범위 | 실행 명령 | 총 테스트 | 통과 | 실패 | 결과 |
| --- | --- | ---: | ---: | ---: | :---: |
| 변경 범위 | `pwsh -NoProfile -File lib/Garden.Harness/src/markdown/guards/Test-MarkdownDocumentConventionGuard.ps1 -Path resume` | 7 | 7 | 0 | ✅ |
| 전체 | `pwsh -NoProfile -File lib/Garden.Harness/src/markdown/guards/Test-MarkdownDocumentConventionGuard.ps1 -Path docs/portfolio` | 56 | 56 | 0 | ✅ |

**실행 일시**: 2026-10-15 11:20

## 계획 평가

| 관점 | 참조 문서 | 평가 항목 | 결과 |
| --- | --- | --- | --- |
| 클린 코드 | `clean-code.md` | 각 도메인 폴더가 오직 하나의 직무 책임만 갖도록 SRP 적용 | ✅ |
| 아키텍처 | `clean-architecture.md` | 백엔드 vs 아키텍처, DevOps vs 인프라, 데스크톱 vs 시스템 프로그래밍 경계 명확화 | ✅ |
| 디자인 패턴 | `design-pattern.md` | Hub & Spoke 정보 아키텍처 일관성 유지 | ✅ |
| 엔터프라이즈 패턴 | `enterprise-application-architecture.md` | BLE 하드웨어 통신을 시스템 프로그래밍 계층으로 응집 | ✅ |
| 리팩토링 | `refactoring.md` | 복합 결합 도메인 냄새 제거 및 원자적 도메인 추출 | ✅ |
| 테스트 품질 | `x-unit-test-patterns.md` | PowerShell 정적 검증 스크립트를 통한 결정론적 검증 | ✅ |
| .NET 도메인·컨벤션 | `dotnet/docs/guide·convention` | 마크다운 및 Notion 구조 리팩토링으로 C# 도메인 코드 변경 없음 | 해당 없음 |

**특이사항:**

없음

## 작업 순서

1. `docs/portfolio/strategy/convention-notion-resume-structure.md`에 9대 단일 책임 도메인 분리 및 BLE 시스템 프로그래밍 편입 규칙을 반영한다.
2. `docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md`를 9대 단일 책임 도메인 구조로 업데이트한다.
3. Notion에서 신규 분리된 4개 도메인 허브(`02. 소프트웨어 아키텍처`, `04. 클라우드 및 온프레미스 인프라`, `06. 웹 디자인 시스템`, `08. 시스템 프로그래밍`)를 생성하고 기존 5개 도메인 허브 제목과 하위 페이지를 재배치한다.
4. `resume/resume-yegun-kim.md` 및 하위 프로젝트 마크다운을 Notion 구조와 1:1로 동기화한다.
5. `resume/README.md`의 전략 문서 설명을 9대 도메인 기준으로 갱신하고 마크다운 가드를 실행하여 검증한다.
