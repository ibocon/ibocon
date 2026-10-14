# 비공개 실무 리포지토리의 Profile README 중심 아키텍처 쇼케이스 구축 계획

---

## 1. 계획 개요

* **문서명**: 전략 1 - 비공개(Private) 핵심 실무 프로젝트의 Profile README 중심 아키텍처 쇼케이스 구축 계획서
* **배경**: `BotanicSoft/Peony`, `MANGOSLABCoLtd/Monolith`, `BotanicSoft/Garden.Cluster` 등 엔지니어의 핵심 성과가 담긴 실무 리포지토리는 모두 **Private**이므로 GitHub Pinned Repositories에 직접 노출할 수 없음.
* **목표**:
  1. 외부인이 비공개 저장소의 소스 코드를 직접 보지 못하더라도, **Profile README의 `Key Engineering Projects` 테이블** 및 연계 기술 문서를 통해 시스템 규모와 기술적 난이도를 직관적으로 파악하도록 구성.
  2. 단순 프로젝트 나열이 아닌 **Problem - Architecture - Impact(정량적 성과)** 중심의 기술 쇼케이스로 승화.

---

## 2. 현황 분석 및 과제 (AS-IS vs TO-BE)

| 구분 | AS-IS | TO-BE (전략 1 적용) |
| :--- | :--- | :--- |
| **정보 노출 방식** | Pinned에는 노출되지 않아 방문자가 실무 역량 인지 불가 | Profile README 상단에 핵심 프로젝트 요약 테이블 배치 |
| **설명 수준** | 단순 프로젝트명과 1줄 설명 | **시스템 아키텍처 패턴, 핵심 난제 해결, 처리 규모** 구조화 명시 |
| **보안 및 규약** | 사내 비즈니스 로직 유출 위험 없이 기술 역량 전달 필요 | **도메인 무관 아키텍처 패턴(Clean Architecture, CQRS, Flux GitOps)** 중심으로 기술 |
| **검증 경로** | 코드 검증 불가 | 블로그 상세 아티클 링크 및 공개 재현 사례와 상호 참조 |

---

## 3. 세부 설계 및 README 테이블 고도화 명세

### 3.1 Key Engineering Projects 테이블 세부 구성안

```markdown
## 🚀 Key Engineering Projects & Architectural Highlights

| 프로젝트 | 시스템 성격 및 규모 | 핵심 아키텍처 & 기술적 기여 | 주요 엔지니어링 성과 |
| :--- | :--- | :--- | :--- |
| **Monolith** | 핵심 데스크톱 앱 및 분산 백엔드 통합 플랫폼 (C# / .NET 9) | • Clean Architecture & Result 패턴 전면 도입<br>• .NET Aspire AppHost 기반 로컬 인프라·서비스 원클릭 기동<br>• WPF / Blazor 하이브리드 수명주기 및 메모리 최적화 | • 5개 분산 하위 시스템 모노레포 통합 (커밋 비중 75%)<br>• 크로스 플랫폼 클라이언트 안정성 확보<br>• 70개+ PR 주도 리팩토링 |
| **Peony** | 이벤트 기반 가계부 마이크로서비스 백엔드 (CQRS / .NET 9) | • Milan Jovanović 원칙 기반 Rich Domain Model 리팩토링<br>• RabbitMQ 비동기 이벤트 버스 및 Outbox 패턴 구현<br>• PostgreSQL 기반 장부 파이프라인 | • 도메인 행위 집중화로 빈혈 모델 해소<br>• 분산 환경 데이터 정합성 보장<br>• 멀티 디바이스 동기화 구조 수립 |
| **Garden.Cluster** | 온프레미스 & 클라우드 쿠버네티스 오케스트레이션 (GitOps) | • Flux v2 기반 선언적 GitOps 파이프라인<br>• OpenBao(Vault) 기반 자동화 시크릿 프로비저닝<br>• Seq & OpenTelemetry 기반 통합 관측성 확보 | • 서비스 배포 자동화 및 무중단 롤아웃<br>• 시크릿 유출 제로 거버넌스 수립<br>• 클러스터 장애 조기 탐지 체계 구축 |
```

---

## 4. 실행 및 액션 플랜

1. **보안 가이드라인 준수**: 사내 고유 비즈니스 키워드, 미공개 고객사 정보, 내부 IP/도메인을 철저히 배제하고 범용 기술 용어로 치환.
2. **README.md 테이블 업데이트**: `ibocon/ibocon`의 `README.md` 내 프로젝트 테이블을 위 고도화 명세로 갱신.
3. **블로그 링크 연계**: 티스토리 블로그(`ibocon.tistory.com`)에 Clean Architecture 및 GitOps 구축 경험담을 비식별화하여 작성하고 각 테이블 행에 아티클 링크 연결.

---

## 5. 기대 효과

* 비공개 리포지토리의 소스 코드를 열람하지 않고도 시니어 엔지니어로서의 아키텍처 리더십과 시스템 복잡도 해결 능력을 즉시 확인 가능.
* 기술 면접 시 테이블에 기재된 아키텍처 키워드(CQRS, Outbox, GitOps)를 중심으로 심도 있는 인터뷰 유도 가능.
