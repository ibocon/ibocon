# 오픈소스 프레임워크 기여 및 심층 트러블슈팅 리포지토리 큐레이션 계획

---

## 1. 계획 개요

* **문서명**: 전략 3 - 오픈소스 프레임워크 기여 및 심층 트러블슈팅 리포지토리 큐레이션 및 Pinned 반영 계획서
* **배경**:
  - 엔지니어의 진짜 기술 깊이는 "단순 API 호출"이 아니라, **프레임워크 내부 소스코드를 분석하고, 런타임 메모리 릭이나 예외를 근본적으로 파헤칠 때** 드러남.
  - `@ibocon`은 공식 `dotnet/maui`에 Blazor 메모리 릭 이슈를 제보하고 이를 재현하는 리포지토리(`maui-blazor-activity-leak-repro`)를 공개하는 등 높은 수준의 오픈소스 디버깅 실적을 보유하고 있음.
* **목표**:
  - 보유 중인 심층 트러블슈팅 및 오픈소스 포크/기여 프로젝트를 발굴하여 Pinned 최우선 후보로 정비하고, 각 저장소의 README를 '문제 해결 포트폴리오'로 탈바꿈시킴.

---

## 2. 큐레이션 대상 핵심 리포지토리 분석

### 2.1 대상 1: `ibocon/maui-blazor-activity-leak-repro` (최우선 추천)
* **활동 성격**: Microsoft 공식 `dotnet/maui` 저장소 이슈 제출 및 메모리 릭 최소 재현 코드(Minimal Repro) 제공
* **관련 이슈**: `[Android] BlazorWebViewHandler never unsubscribes from RootComponents.CollectionChanged on disconnect, retaining the old MauiContext and finished Activity`
* **엔지니어링 가치**:
  - Android 액티비티 수명주기와 MAUI Blazor 핸들러 간 이벤트 구독 해제 누락으로 발생하는 심각한 GC 메모리 누수 발견.
  - 일반 개발자가 찾기 힘든 프레임워크 코어 레벨의 메모리 누수 원인을 프로파일링하고 최소 재현 환경을 구축하여 MS 코어 팀에 전달.
* **정비 계획**:
  - 리포지토리의 README.md를 보강: **[배경 - 문제 현상 - GC/힙 덤프 분석 증거 - 원인 코드 라인 - 해결 방안]** 구조로 정리하여 완벽한 기술 아티클화.

### 2.2 대상 2: `ibocon/SVG` (C# 그래픽스 / 라이브러리 포크 및 성능 개작)
* **활동 성격**: `svg-net/SVG` 공식 라이브러리를 포크하여 내부 렌더링, 폰트 렌더, 비트맵 파이프라인 등을 현대화하거나 최적화한 실적
* **엔지니어링 가치**:
  - 대규모 인쇄(nemonic) 및 그래픽 렌더링 파이프라인에서 벡터 SVG 파싱 성능 및 호환성을 다룬 깊이 있는 시스템 엔지니어링 경험 증명.
* **정비 계획**:
  - Fork 목적과 upstream 대비 개선 사항(성능 패치, 한글 폰트 처리, 메모리 최적화 등)을 리포지토리 상단 README에 명시.

---

## 3. 리포지토리 메타데이터 및 Pinned 설정 명세

```markdown
[ Pinned Repositories 배치안 (트러블슈팅 & 기여 중심) ]

1. ibocon/ibocon
   - Desc: GitHub Profile README & Engineering Dashboard
2. ibocon/maui-blazor-activity-leak-repro
   - Desc: Minimal reproduction for dotnet/maui BlazorWebViewHandler GC memory leak issue
3. ibocon/SVG
   - Desc: Optimized fork of svg-net/SVG for high-performance rendering & bitmap pipelines
4. ibocon/dotnet-clean-architecture-template (전략 2 산출물 연계)
   - Desc: Production-ready .NET 9 Clean Architecture template with DDD & Architecture Tests
```

---

## 4. 실행 세부 지침

1. **`maui-blazor-activity-leak-repro` README.md 고도화**:
   - `dotnet/maui`의 이슈 링크(`#xxxx`)를 명시.
   - 메모리 프로파일러(dotMemory, Visual Studio Diagnostics) 스크린샷 또는 분석 다이어그램 첨부.
   - 워크어라운드 코드(Dispose 시 수동 이벤트 핸들러 분리 방법) 수록.
2. **Pinned 등록**:
   - 프로필 메인의 `Customize your pins`에서 위 리포지토리들을 선택 및 고정.

---

## 5. 기대 효과

* 시니어/리드급 기술 면접관에게 **"프레임워크 내부 소스코드를 읽고 메모리/GC 레벨의 치명적인 결함을 직접 추적·해결할 수 있는 개발자"**라는 강력한 차별점 부여.
* 오픈소스 커뮤니티 기여 지표로 작용하여 신뢰도 대폭 상승.
