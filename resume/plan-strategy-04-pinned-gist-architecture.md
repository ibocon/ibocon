# Pinned Gist 및 동적 아키텍처 스니펫을 활용한 설계 역량 시각화 계획

---

## 1. 계획 개요

* **문서명**: 전략 4 - Pinned Gist 및 동적 아키텍처 스니펫을 활용한 설계 역량 시각화 계획서
* **배경**:
  - GitHub의 Pinned 슬롯에는 리포지토리(Repository)뿐만 아니라 **Gist(gist.github.com)**도 고정할 수 있음.
  - 리포지토리 개수가 적거나 비공개일 때, Pinned Gist를 활용하면 **"아키텍처 설계 원칙", "코딩 시간대 통계", "핵심 C# 엔지니어링 치트시트"** 등을 프로필 상단 핀 영역에 직접 노출하여 시각적 다양성과 지적 자산을 보여줄 수 있음.
* **목표**:
  - Pinned Gist 1~2개를 생성하여 리포지토리 핀과 조화롭게 배치함으로써 프로필의 기술적 완성도를 높임.

---

## 2. Pinned Gist 후보 유형 및 세부 설계

### 2.1 후보 A: `productive-box` (코딩 습관 및 시간대 통계)
* **내용**: GitHub Actions를 통해 오전/오후/저녁 시간대별 커밋 활동을 자동 집계하여 ASCII 바로 실시간 표시하는 동적 Gist.
* **표시 예시**:
  ```text
  🌞 Morning     1,240 commits  ████░░░░░░░░░░  12.2 %
  🌆 Daytime     4,850 commits  ██████████████  47.8 %
  🌃 Evening     3,410 commits  ██████████░░░░  33.6 %
  🌙 Night         659 commits  ██░░░░░░░░░░░░   6.4 %
  ```
* **엔지니어링 가치**: 주야간에 걸친 꾸준한 개발 습관과 생산성을 직관적으로 전달.

### 2.2 후보 B: `software-architecture-manifesto.md` (아키텍처 설계 원칙 Gist)
* **내용**: `@ibocon`이 개발 시 준수하는 핵심 소프트웨어 엔지니어링 철학을 마크다운 Gist로 고정.
* **Gist 수록 내용 요약**:
  1. **Clean Architecture & Separation of Concerns**: 외부 프레임워크로부터 독립된 순수 도메인 코어.
  2. **Rich Domain Model vs Anemic Domain Model**: 비즈니스 불변식(Invariants)은 엔티티 내부에서 보호.
  3. **Explicit Error Handling with Result Pattern**: 예외 기반 제어 배제, 명시적 `Result<T>` 반환.
  4. **Strict Testing & Verification**: Given-When-Then, 빠른 피드백 루프, 아키텍처 규칙 검증.
* **엔지니어링 가치**: 코드를 열어보지 않고도 핀 카드만으로 엔지니어의 확고한 개발 철학을 즉시 전달.

---

## 3. 구축 절차 및 연동 방법

### 3.1 Gist 생성
1. [gist.github.com](https://gist.github.com) 접속
2. 파일명: `architecture-principles.md` (또는 `clean-code-guidelines.md`)
3. Public Gist로 생성하여 저장

### 3.2 Pinned 등록
1. [https://github.com/ibocon](https://github.com/ibocon) 접속
2. **Customize your pins** 클릭
3. 검색창 우측 또는 탭에서 **Gists** 필터 선택
4. 생성한 Gist 체크 후 **Save pins** 클릭

---

## 4. 최종 통합 Pinned 레이아웃 (총 6개 슬롯 최적화)

| 슬롯 | 유형 | 대상 이름 | 전달하는 핵심 가치 |
| :---: | :---: | :--- | :--- |
| **Pin 1** | Repo | `ibocon/ibocon` | Profile README 대시보드 및 전체 링크 허브 |
| **Pin 2** | Repo | `ibocon/dotnet-clean-architecture-template` *(전략 2)* | 프로덕션급 클린 아키텍처 설계 및 구현 실력 |
| **Pin 3** | Repo | `ibocon/maui-blazor-activity-leak-repro` *(전략 3)* | 프레임워크 런타임 버그 추적 및 메모리 릭 디버깅 실력 |
| **Pin 4** | Repo | `ibocon/SVG` *(전략 3)* | 그래픽/벡터 렌더링 파이프라인 및 오픈소스 개작 실력 |
| **Pin 5** | Gist | `architecture-principles.md` *(전략 4)* | 엔지니어링 철학과 설계 원칙(Rich Domain / Result 패턴) |
| **Pin 6** | Gist | `productive-box` *(전략 4)* | 시간대별 커밋 분포 및 연간 1만 커밋의 지속성 시각화 |

---

## 5. 기대 효과

* Private 저장소라는 제약을 완벽히 극복하고, 6개의 핀 슬롯을 **"템플릿 코드 - 디버깅 실적 - 오픈소스 - 설계 철학 - 개발 생산성"**으로 빈틈없이 채워 압도적인 신뢰도 구축.
