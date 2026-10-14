# 공개 .NET Clean Architecture 템플릿 리포지토리 구축 및 Pinned 고정 계획

---

## 1. 계획 개요

* **문서명**: 전략 2 - 공개(Public) `.NET Clean Architecture Starter Kit` 템플릿 리포지토리 구축 및 Pinned 고정 계획서
* **배경**: 실무 코드는 Private이라 외부에 직접 노출할 수 없으므로, 엔지니어 본인의 **설계 철학, 코드 컨벤션, 테스트 전략, 폴더 구조**를 집약한 오픈소스 보일러플레이트(Template Repository)를 제작하여 Pinned 최상단에 고정함.
* **목표 리포지토리명**: `ibocon/dotnet-clean-architecture-template` (또는 `clean-architecture-starter-kit`)

---

## 2. 템플릿 리포지토리 아키텍처 스펙 설계

```
Solution: CleanArchitecture.Template.sln
├── src/
│   ├── Domain/                 # 엔티티, 도메인 이벤트, Value Object, Result 패턴 (의존성 제로)
│   ├── Application/            # Use Cases, CQRS Commands/Queries, DTO, FluentValidation
│   ├── Infrastructure/         # EF Core, PostgreSQL/SQL Server, Outbox, 외부 서비스 어댑터
│   └── Presentation.Api/       # ASP.NET Core Web API, Minimal APIs, 글로벌 예외 핸들러, Scalar/Swagger
└── tests/
    ├── Domain.UnitTests/       # Given/When/Then 패턴 단위 테스트 (FluentAssertions)
    ├── Application.UnitTests/  # 핸들러 및 비즈니스 유효성 검증
    └── ArchitectureTests/      # NetArchTest를 통한 클린 아키텍처 의존성 역전 규칙 자동 검증
```

### 2.1 주요 차별화 엔지니어링 포인트
1. **Rich Domain Model & Always Valid Entity**: 빈혈 도메인 모델(Anemic Domain Model)을 배제하고, 객체 생성 및 상태 변경 시 도메인 규칙을 강제하는 엔티티 구현.
2. **Garden.Result 패턴 탑재**: 예외를 통한 흐름 제어를 피하고, 철저한 `Result<T>` 반환을 통한 함수형 에러 핸들링.
3. **아키텍처 단위 테스트 (NetArchTest)**: Domain 레이어가 상위 레이어를 참조하지 않음을 xUnit 테스트 코드로 자동 검증하는 아키텍처 가드 포함.
4. **FastBuild & CI 파이프라인**: GitHub Actions CI 워크플로(`.github/workflows/ci.yml`)를 탑재하여 빌드 및 테스트 자동화 증명.

---

## 3. Pinned Repositories 등록 및 리포지토리 큐레이션

### 3.1 GitHub 리포지토리 설정 명세
* **Repository Type**: Public + `Template repository` 옵션 체크 활성화
* **Description**: `Production-ready .NET 9 Clean Architecture template with Rich Domain Model, CQRS, Result Pattern, and Architecture Unit Tests`
* **Topics (Tags)**: `dotnet`, `csharp`, `clean-architecture`, `cqrs`, `ddd`, `result-pattern`, `template`, `xunit`
* **README.md 필수 포함 섹션**:
  - 시스템 아키텍처 레이어 다이어그램 (Mermaid)
  - 채택한 설계 원칙 (Clean Architecture, SOLID, Options Pattern)
  - 테스트 실행 및 템플릿 사용 방법 (`dotnet new install`)

---

## 4. 단계별 구축 일정 (WBS)

| 단계 | 작업 항목 | 세부 산출물 |
| :---: | :--- | :--- |
| **Phase 1** | 솔루션 스캐폴딩 | 도메인, 애플리케이션, 인프라, API 프로젝트 구조 생성 |
| **Phase 2** | 핵심 공통 라이브러리 탑재 | `Result<T>`, `Entity<T>`, `IDomainEvent`, Outbox 인터페이스 구현 |
| **Phase 3** | 테스트 스위트 구축 | xUnit 기반 UseCase 단위 테스트 및 `NetArchTest` 아키텍처 규칙 테스트 |
| **Phase 4** | GitHub Actions CI 연동 | PR 및 푸시 시 자동 빌드, 테스트, 린트 검증 파이프라인 |
| **Phase 5** | 템플릿 등록 및 Pinned 반영 | Template 옵션 활성화 후 `ibocon` 프로필의 Pinned Repositories에 고정 |

---

## 5. 기대 효과

* 채용 담당자와 기술 면접관이 리포지토리를 클릭했을 때 **"현업에서 바로 쓸 수 있는 수준의 모던 .NET 설계 실력"**을 코드로 직접 입증.
* 개발 생태계 내 다른 개발자들의 Star 및 Fork 유입으로 깃허브 인지도 상승.
