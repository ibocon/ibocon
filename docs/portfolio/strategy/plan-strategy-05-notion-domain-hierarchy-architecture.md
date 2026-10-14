# 🏛️ 전략 5 — 노션 이력서 도메인별 계층 구조 (폴더 트리 모델) 설계서

---

## 1. 개요 및 배경

* **문서명**: 전략 5 — 노션 이력서 도메인별 계층 구조 (폴더 트리 모델) 설계서
* **작성자**: 김예건 ([@ibocon](https://github.com/ibocon) / `wlfka102@gmail.com`)
* **관리 위치**: `docs/portfolio/strategy/plan-strategy-05-notion-domain-hierarchy-architecture.md` (Local SoT)
* **목표 Notion 메인**: [📄 이력서 — 김예건](https://app.notion.com/p/3dd475218675811299b0e3d6b2baa43d)
* **대원칙 선언**:
  > **"최상위 폴더 자체를 '프로젝트 단위'로 구성하는 것은 완전 금지(Anti-Pattern)한다."**  
  > 채용 담당자(HR 리크루터, 테크 리드)에게 `Monolith`, `Argon`, `Peony`, `Lithium` 같은 사내/개인 프로젝트 이름은 사전 지식이 없어 생소하고 난해한 암호일 뿐입니다.  
  > 따라서 **최상위 폴더는 100% 채용 시장에서 통용되는 '기술 도메인 / 직무 전문성 / 엔지니어링 영역(Domain-First)'**으로만 구성하며, 프로젝트명은 하위 상세 페이지의 보조 식별자로만 사용합니다.

---

## 2. 핵심 설계 원칙 및 사용자 피드백 반영 이력

```text
[ 채용 담당자 관점의 핵심 설계 원칙 ]
1. 최상위 프로젝트명 배치 절대 금지 (Domain-First)
   - 최상위 폴더는 채용 공고(JD) 및 업계 표준 직무 명칭(백엔드, 인프라, 디자인시스템, DevEx 등)으로만 정의.
   - 프로젝트명(Monolith, Argon, Peony 등)은 하위 문서 제목의 괄호 병기로만 한정.
2. 하위 페이지 명명 규약 (Role-First Title Rule)
   - 하위 페이지 역시 프로젝트명 단독 표기(예: 'Monolith')를 금지.
   - 반드시 '[직무/기술 역할] — 핵심 성과 및 스택 (프로젝트명)' 형식으로 작성.
   - 예: '[전사 백엔드] 대규모 트랜잭션 및 전사 통합 모듈 모노레포 (.NET 9 / Monolith)'
3. Peony와 Garden 생태계의 도메인별 프로젝트 단위 분산
   - Peony는 단순 백엔드가 아니라 백엔드 마이크로서비스 9종, .NET MAUI 모바일 앱, K8s 인프라, 디자인 시스템, AI 하네스가 망라된 복합 생태계임.
   - Peony를 백엔드 단일 페이지로 축소하지 않고, 각 도메인 레이어에서 '독립 프로젝트 단위'로 분리 서술.
4. Garden.Razor & Penpot 디자인 시스템 정식 도메인 편입
   - 오픈소스 디자인 도구 Penpot과 C# Blazor/Razor 컴포넌트 라이브러리(Garden.Razor), 컴포넌트 갤러리를 연동한 디자인 시스템 구축 실적을 독립 도메인/프로젝트로 명시.
5. 비선호 기술(Flutter) 완전 제외
   - 모바일은 Lithium 중심의 무선 하드웨어 연동 및 BLE 패킷 최적화에 집중.
```

### 2.1 절대 금지 안티패턴(Anti-Pattern) 및 폐기 사유 기록 (재발 방지)

과거 검토 과정에서 제기되었으나 채용 공학적 관점에서 심각한 결함이 확인되어 **영구 폐기 및 금지된 안티패턴**을 기록합니다. 향후 어떠한 이력서 개편에서도 동일한 실수를 반복하지 않도록 합니다.

| 폐기된 안티패턴 모델 | 설계 내용 | 폐기 및 절대 금지 사유 |
| :--- | :--- | :--- |
| **⛔ 안티패턴 A**<br>`5대 프로젝트 단위 최상위 폴더 모델` | 최상위 폴더를 `[Monolith]`, `[Argon]`, `[Peony]` 등 사내 프로젝트 단위로 구성하고 하위에 도메인 기술 | **1. 채용 담당자의 인지 장벽 극대화**: 외부 리크루터나 테크 리드는 지원자의 사내 코드명에 대한 배경지식이 전무하여 암호처럼 느껴짐.<br>**2. 10초 스캔 실패**: 채용 담당자가 찾는 것은 "백엔드 개발자인가? 인프라 엔지니어인가?"이지 프로젝트명이 아님.<br>**3. JD 매칭 불가능**: 채용 공고의 자격 요건 키워드와 최상위 폴더가 매칭되지 않아 1차 서류 탈락 위험 초래. |
| **⛔ 안티패턴 B**<br>`회사 vs 자체 플랫폼 2대 축 분리형` | 최상위 폴더를 `01. 엔터프라이즈(MANGOSLAB)`와 `02. 자체 플랫폼(BotanicSoft)`으로 양분 | **1. 지원자 중심의 편의적 분류**: 공급 주체(회사/개인)를 가르는 것은 지원자 개인의 관점일 뿐, 채용 담당자의 관심사가 아님.<br>**2. 기술 전문성 파편화**: 동일한 백엔드/인프라 역량이 회사 폴더와 자체 플랫폼 폴더로 양분되어 역량의 총량이 분산되어 보임. |

```mermaid
graph TD
    Root[이력서 김예건 메인]

    D1[01 .NET 백엔드 및 분산 아키텍처]
    D2[02 DevOps 및 클라우드 인프라]
    D3[03 Windows 데스크톱 및 시스템 프로그래밍]
    D4[04 모바일 및 웹 프론트엔드 엔지니어링]

    Root --> D1
    Root --> D2
    Root --> D3
    Root --> D4

    subgraph 도메인 1 백엔드 상세
        D1 --> P1_1[전사 통합 모듈 모노레포 Monolith]
        D1 --> P1_2[이벤트 주도 CQRS 가계부 마이크로서비스 Peony]
        D1 --> P1_3[비동기 잡 큐 AI 마이크로서비스 NemonicStudy]
    end

    subgraph 도메인 2 인프라 및 DevEx 상세
        D2 --> P2_1[온프레미스 듀얼 사이트 K8s DR Argon]
        D2 --> P2_2[하이브리드 K8s 및 100TB Ceph 스토리지 Garden.Cluster]
        D2 --> P2_3[AI 에이전트 하네스 및 빌드 70퍼센트 가속 Garden.Harness]
    end

    subgraph 도메인 3 데스크톱 상세
        D3 --> P3_1[Windows 스마트 메모 프린터 nemonic Desktop]
        D3 --> P3_2[OS 독립형 USB Bluetooth 저수준 통신 SDK]
    end

    subgraph 도메인 4 모바일 및 프론트엔드 상세
        D4 --> P4_1[NET MAUI 가계부 앱 Peony Mobile]
        D4 --> P4_2[FINECUBE 컬러 라벨 모바일 앱 및 BLE Lithium]
        D4 --> P4_3[Penpot 토큰 기반 웹 디자인 시스템 Garden.Razor]
    end
```

---

## 3. 최상위 도메인 중심 노션 폴더 구조 및 최종 채택안

> **공식 채택 결정**:  
> 사람인, 점핏, 잡플래닛, 원티드 등 국내 주요 테크 채용 플랫폼의 실제 C# .NET 백엔드, DevOps/SRE, Windows 데스크톱, BLE IoT 모바일 채용 공고(JD) 전수 조사 결과([`recruitment-jd-benchmarking-references.md`](./recruitment-jd-benchmarking-references.md))를 바탕으로, HR 리크루터 및 테크 리드의 1차 서류 통과율과 직무 적합도를 극대화하는 **[조합 4: 4대 채용 공고(JD) 직무 직결 모델]을 최종 표준안으로 공식 채택**합니다.

---

### [최종 확정 채택안] 4대 채용 공고(JD) 직무 직결 모델 (조합 4) — ⭐ **최종 확정**
> **특징**: 국내외 테크 기업의 4대 채용 포지션(백엔드, DevOps/인프라, Windows 데스크톱, 모바일/프론트엔드)에 100% 대응하며, DevEx와 디자인 시스템을 각 기술 영역에 알맞게 내재화하여 서류 검토자가 체크리스트를 확인하듯 즉각적으로 직무 적합성을 판정할 수 있는 구조.

```text
├── 📁 01. .NET 백엔드 & 분산 아키텍처 (C#, Clean Architecture, DDD, CQRS)
│   ├── 📄 [전사 백엔드] 대규모 트랜잭션 처리 및 전사 통합 모듈 모노레포 (.NET 9 / Monolith)
│   ├── 📄 [분산 메시징] RabbitMQ & Outbox 패턴 기반 이벤트 주도 마이크로서비스 (Peony Backend)
│   └── 📄 [AI 파이프라인] 비동기 잡 큐 기반 AI/OCR 마이크로서비스 (NemonicStudy)
│
├── 📁 02. DevOps & 클라우드 인프라 (K8s, GitOps, On-Premise, Ceph, DevEx)
│   ├── 📄 [K8s GitOps & DR] 온프레미스 듀얼 사이트 K8s 구축 & 재해복구 체계 (Argon / Garden.Cluster)
│   ├── 📄 [분산 스토리지] 100TB급 Ceph 분산 스토리지 및 무중단 리밸런싱 운영
│   └── 📄 [DevEx & CI/CD] 4대 AI 에이전트 하네스(Garden.Harness) & 빌드 70% 가속 파이프라인
│
├── 📁 03. Windows 데스크톱 & 시스템 프로그래밍 (WPF, Win32, 하드웨어 제어)
│   ├── 📄 [데스크톱 클라이언트] 50만 대 누적 기기 제어 및 레거시 .NET 9 현대화 (nemonic Desktop)
│   └── 📄 [디바이스 드라이버] OS 독립형 USB / Bluetooth LE 저수준 통신 프로토콜 설계
│
└── 📁 04. 모바일 & 웹 프론트엔드 엔지니어링 (Android, iOS, Blazor, Penpot)
    ├── 📄 [모바일 클라이언트] .NET MAUI 크로스플랫폼 가계부 앱 (Peony Mobile)
    ├── 📄 [하드웨어 연동 앱] FINECUBE 컬러 라벨 앱 & BLE 무손실 패킷 스트리밍 (Lithium)
    └── 📄 [디자인 시스템] Penpot 토큰 동기화 Blazor/Razor 웹 컴포넌트 라이브러리 (Garden.Razor)
```

---

### [베리에이션 5] 3대 엔터프라이즈 시스템 계층 모델 (Core / Platform / Edge)
> **특징**: 시스템의 기능 위계(코어 비즈니스 백엔드 → 전사 공통 플랫폼/인프라/디자인시스템 → 엣지 엔드포인트 디바이스) 3대 레이어를 최상위 도메인 폴더로 구성한 아키텍처 중심 모델.

```text
├── 📁 01. 백엔드 & 분산 시스템 (Core Business Services)
│   ├── 📄 [전사 백엔드] 전사 통합 .NET 9 백엔드 모노레포 (14개 서비스 통합 / Monolith)
│   ├── 📄 [분산 메시징] 이벤트 주도 CQRS 분산 백엔드 & Outbox 패턴 (Peony Backend)
│   └── 📄 [AI 파이프라인] 비동기 OCR/요약 잡 큐 마이크로서비스 (NemonicStudy)
│
├── 📁 02. 플랫폼, 인프라 & 디자인 시스템 (Foundations & Platforms)
│   ├── 📄 [K8s 인프라] 온프레미스 듀얼 사이트 K8s & GitOps 자동화 (Argon / Garden.Cluster)
│   ├── 📄 [디자인 시스템] Penpot 토큰 동기화 웹 디자인 시스템 & 컴포넌트 갤러리 (Garden.Razor)
│   └── 📄 [DevEx 거버넌스] AI 코딩 에이전트 하네스 & 빌드 가속 파이프라인 (Garden.Harness)
│
└── 📁 03. 하드웨어 연동 디바이스 & 엣지 앱 (Endpoint Products)
    ├── 📄 [데스크톱 엔진] Windows 스마트 메모 프린터 클라이언트 — 8년 라이프사이클 (nemonic Desktop)
    ├── 📄 [모바일 앱] .NET MAUI 가계부 앱(Peony) & BLE 컬러 라벨 앱(Lithium)
    └── 📄 [디바이스 SDK] USB / Bluetooth 저수준 하드웨어 프로토콜 라이브러리
```

---

## 4. 도메인 허브 페이지(상위 폴더) 표준 템플릿 명세

각 도메인 상위 페이지는 채용 담당자에게 **전문 분야의 스케일과 비즈니스 가치**를 30초 내에 전달할 수 있도록 아래 표준 템플릿으로 구성합니다.

### 4.1 허브 페이지 레이아웃
1. **Header Block**: 도메인 명칭 및 영문 표기, 핵심 역할 요약
2. **Executive Summary Table**:
   - `[주요 기술 스택]`, `[해결한 핵심 엔지니어링 난제]`, `[대표 비즈니스 정량 지표]`, `[포괄 프로젝트 수]`
3. **Architecture Philosophy (철학)**:
   - 해당 도메인 개발 시 준수하는 원칙 (예: 백엔드의 경우 Clean Architecture & Event-Driven, 인프라의 경우 GitOps & Zero-Downtime, 디자인 시스템의 경우 Single Token SoT)
4. **Project Gallery Grid (하위 프로젝트 링크 카드)**:
   - 각 하위 상세 페이지로 연결되는 링크 카드 (배경 이미지, 프로젝트 명, 핵심 기술, 기간 포함)

---

## 5. 41개 Git 저장소 + Garden/Peony 생태계 종합 수렴 매핑표

| 도메인 계층 | 포괄 저장소 / 프로젝트 목록 | 대표 상세 페이지 (TO-BE) |
| :--- | :--- | :--- |
| **01. 백엔드 서비스 플랫폼** | `Monolith`, `Oxygen.Hub`, `Oxygen.Teams`, `Oxygen.Slack`, `Oxygen.Zapier`, `Oxygen.Web`, `Oxygen.Amplitude`, `Oxygen.Jira`, `Oxygen.Nemonic.Pro.SettingsApp`, `Radium`, `Mangoslab`, `Zinc.NemonicStudy`, `Zinc.NemonicStudy.Bff.Api`, `Zinc.NemonicStudy.Service.Ocr`, `Zinc.NemonicStudy.Service.Summary`, `Zinc.NemonicAi` | 1. [전사 백엔드] 대규모 트랜잭션 및 모듈 모노레포 (Monolith)<br>2. [분산 메시징] 이벤트 주도 CQRS 가계부 마이크로서비스 (Peony Backend)<br>3. [AI 파이프라인] 비동기 잡 큐 & OCR/요약 마이크로서비스 (NemonicStudy) |
| **02. 클러스터 인프라 플랫폼** | `argon`, `kc5`, `kc6`, `Mangoslab.IaC`, `History`, `Garden.Cluster`, `Rook-Ceph Cluster` | 1. [K8s GitOps] 온프레미스 듀얼 사이트 K8s (Argon)<br>2. [분산 스토리지] 하이브리드 K8s & Rook-Ceph 100TB 운영 (Garden.Cluster) |
| **03. 디자인 시스템 & 웹 프론트엔드** | `Garden.Razor`, `Garden.Razor.Gallery`, `Penpot Design System (Tokens)` | 1. [디자인 시스템] Penpot 토큰 동기화 웹 디자인 시스템 (Garden.Razor)<br>2. [컴포넌트 갤러리] Blazor WASM 인터랙티브 UI 갤러리 |
| **04. 개발자 경험 & AI 거버넌스** | `Mangoslab.Pipeline`, `Garden.Harness` | 1. [CI/CD 가속] GitHub Actions 러너 최적화 — 빌드 70% 단축<br>2. [AI 하네스] 4대 AI 코딩 에이전트 통합 거버넌스 (Garden.Harness) |
| **05. 하드웨어 연동 데스크톱 제품** | `NemonicBasicWindows`, `NemonicLabelWindows`, `Nemonic.Ampv`, `MemoView`, `Mangoslab.Usb`, `Mangoslab.Nemonic`, `Mangoslab.Bluetooth`, `Firmware`, `Firmware.TestUtility`, `MIP-301-Centerm-FW-Test` | 1. [데스크톱 클라이언트] Windows 스마트 메모 프린터 엔진 (nemonic Desktop)<br>2. [디바이스 드라이버] 저수준 USB/Bluetooth 통합 SDK |
| **06. 모바일 & 무선 디바이스 앱** | `Lithium`, `Sulfur`, `Mangoslab.Drawing`, `Peony Mobile (.NET MAUI)`, `NemonicBasicAndroid`, `NemonicBasiciOS` | 1. [모바일 클라이언트] .NET MAUI 크로스플랫폼 가계부 앱 (Peony Mobile)<br>2. [무선 통신 앱] FINECUBE 컬러 라벨 모바일 앱 & BLE 스트리밍 (Lithium) |

---

## 6. 기대 효과 및 채용 경쟁력

1. **채용 담당자 인지 장벽 완전 제거 (Domain-First)**:
   - 노션 사이드바를 열었을 때 생소한 프로젝트 코드명 대신 **`01. 백엔드`, `02. 인프라`, `03. 디자인시스템`, `04. DevEx`, `05. 데스크톱`, `06. 모바일`**로 직무 전문성이 즉각 전달되어 1차 서류 스캔 시간 10초 내에 직무 적합성 증명 완료.
2. **Peony 및 Garden 생태계의 온전한 가치 전달**:
   - Peony의 백엔드와 모바일 앱, Garden의 인프라·디자인시스템·DevEx가 각 도메인의 '독립 프로젝트 단위'로 분리되어, 복합적인 풀스택 플랫폼 구축 역량이 선명하게 드러남.
3. **디자인 시스템 & Penpot 구축 역량 공식화**:
   - 오픈소스 디자인 도구 Penpot과 C# Blazor/Razor를 연결한 디자인 토큰 동기화 파이프라인을 단독 도메인/프로젝트로 조명하여, 프론트엔드 및 디자인 협업 생산성 개선 역량 입증.
