# 🖨️ [데스크톱 클라이언트] WYSIWYG 인쇄 엔진 & .NET 9 현대화 (nemonic)

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🖨️ [데스크톱 클라이언트] WYSIWYG 인쇄 엔진 & .NET 9 현대화 (nemonic)](https://app.notion.com/p/3dd4752186758193b90bc453e00b9b25)  
> **최종 동기화 일시**: 2026-10-14

---

<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2017.07 – 현재 (초기 개발 2017.07–2018.05 · 현대화 2026.09–)</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>망고슬래브 · Windows 클라이언트·서버 개발, 아키텍처 현대화</td>
</tr>
<tr>
<td>기여</td>
<td>커밋 177 / 778 (전체 2위) · 초기 1.2 → 1.8 릴리스 주도, 2026 .NET 9 이관</td>
</tr>
<tr>
<td>상태</td>
<td>운영 중 · 최신 배포 1.34.1 (2026.07) · Mango SDK 이관 브랜치 통합 완료(2026.09)</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`.NET 9` `WinForms` `WPF` `MVVM 리팩토링` `USB 프린터 통신` `Mango SDK` `ASP.NET Core` `MySQL` `WiX` `VS Installer Projects` `코드 서명` `Jenkins`</td>
</tr>
</table>
## 개요
스마트 메모 프린터 nemonic의 Windows 데스크톱 앱과 메모 동기화 서버를 개발한 프로젝트입니다. 입사 직후 첫 상용 버전(1.2)부터 1.8까지 기능·구조·배포 체계를 세웠고, 8년 뒤 재참여해 .NET Framework 4.8 레거시를 .NET 9와 사내 공용 SDK(Mango) 기반으로 이관하며 코드 수준 구조 설계서를 정리했습니다.
## 기술 스택
<table fit-page-width="true" header-row="true">
<tr>
<td>영역</td>
<td>구성</td>
</tr>
<tr>
<td>데스크톱 앱</td>
<td>`Nemonic.Application` — .NET 9 (`net9.0-windows`, SDK 스타일 csproj) · WinForms 중심 + WPF(Dropbox 로그인) · 이벤트 기반 MVVM(`MemoViewModel`/`LayerViewModel`) · `.nemo` JSON 문서 포맷(버전 전략 리더로 하위 호환)</td>
</tr>
<tr>
<td>장치 연동</td>
<td>사내 공용 SDK `Mango`(`Mango.Nemonic` · `Mango.Usb`, Monolith 저장소) 프로젝트 참조 · `IPrinterDiscovery` 기반 장치 탐색 · MIP-001/101/201/301 모델 매핑 · Sierra 오차확산 디더링 파이프라인(Resize → Gamma → Dithering)</td>
</tr>
<tr>
<td>보조 프로세스</td>
<td>`Nemonic.AMPV` — 프린터 사용정보 수집·HTTPS 전송 별도 실행 파일(Mutex 단일 실행, 14일/1일 주기)</td>
</tr>
<tr>
<td>서버</td>
<td>`Nemonic.Server` — [ASP.NET](http://ASP.NET) Core MVC `/memos` CRUD · EF Core + Pomelo MySQL · Facebook Graph API 인증 · `(UserId, MemoName)` 복합 키</td>
</tr>
<tr>
<td>외부 연동</td>
<td>AWS S3 버전 확인·자동 업데이트, Dropbox API 업로드, Windows WMI/Spooler, Google Analytics(현재 비활성)</td>
</tr>
<tr>
<td>배포</td>
<td>WiX MSI/부트스트래퍼(초기) → Visual Studio Installer Projects 한·영 MSI/EXE · signtool 코드 서명 · Jenkins 빌드 트리거 · Google Drive 릴리스 보관소</td>
</tr>
</table>
## 구성 요소
- **Nemonic.Application** — 메모 편집·저장·출력 UI. `Main`(진입점·전역), `Model`/`ViewModel`(문서·레이어 상태), `Module`(DataManager·ConfigManager·RebootManager·PrinterManager·Dropbox·Updater), `View`/`O_View`(신·구 뷰 계층)로 구성. 약 141개 C# 파일, 3만 LOC.
- **Mango SDK 어댑터** — `IPrinterManager` 인터페이스와 `MangoPrinterQueryBridge`로 WMI 직접 질의를 SDK 탐색 결과로 일원화. 기존 `Nemonic.Library`·`Nemonic.Usb.Dll` 로컬 프로젝트를 대체.
- **Nemonic.AMPV** — 출력 후 조건부 기동되는 장비 사용량 수집 프로세스. `MangoDiscoveryBridge`로 SDK 장치 탐색 이관.
- **Nemonic.Server** — 메모 동기화 REST API와 MySQL 스키마(`nemonic.sql`), 컨트롤러 테스트 프로젝트.
- **설치 프로젝트** — `Nemonic.Installer`/`Nemonic.Installer_En`(.vdproj), WiX `Nemonic.MSI`·`Nemonic.Executable`·`Driver.MSI`.
## 주요 작업
### 초기 개발 · 1.2 → 1.8 (2017.07 – 2018.05, 커밋 176)
- **WYSIWYG 편집·출력 엔진** — 화면과 열전사 출력의 크기·회전 불일치를 해결. 용지 4종(72×72·72×48·96×72·20×72mm) × 점착면 4방향 회전, DPI 대응, 모델 데이터만으로 인쇄 가능하도록 뷰 의존 제거
- **MVVM 구조 전환** — 한 파일에 몰려 있던 WinForms 코드를 `MemoViewModel`/`LayerViewModel`/`LayerModel` 파생과 이벤트 시스템으로 재구성. 레이어 팩토리·Command 패턴 적용, `.nemo` 리더를 Strategy 패턴(V0/V1)으로 분리해 하위 호환 확보
- **장치·펌웨어 기능** — USB 직접 통신으로 프린터 템플릿 저장, 펌웨어 업데이트 기능, 카트리지 감지 기반 용지 자동 결정
- **메모 동기화 서버** — [ASP.NET](http://ASP.NET) Core + MySQL `/memos` API 설계·구현·테스트, Facebook 로그인 연동, 데스크톱 클라이언트 작성(프로토타입 후 비활성)
- **클라우드·분석 연동** — S3 기반 자동 업데이트 모듈화, Dropbox 업로드(WPF OAuth 뷰), Google Analytics 비동기 이벤트 전송 빌더
- **운영 안정성** — 로그 시스템 도입, 재시작 복구(`restart.json`) 모듈 분리, 임시 저장 우선 정책, 첫 단위 테스트 프로젝트 도입
- **배포 체계 수립** — WiX MSI·부트스트래퍼 번들, 드라이버 MSI 전환, 코드 서명 자동화(ClickOnce → 로컬 signtool), Jenkins 빌드 트리거, 한·일 현지화 문자열
- 2017.11 정부 과제 납품 버전 완료
### 현대화 · Mango 의존 마이그레이션 (2026.09 –)
- **.NET Framework 4.8 → .NET 9** — `Nemonic.Application`·`Nemonic.AMPV`·`Nemonic.Test`를 SDK 스타일 csproj + `PackageReference`로 전환(`packages.config`·`app.config` 제거, 2,000여 줄 프로젝트 파일 정리)
- **로컬 라이브러리 제거·SDK 통합** — `Nemonic.Library`·`Nemonic.Usb.Dll` 프로젝트를 삭제하고 사내 공용 `Mango` 프로젝트 참조로 대체. 남는 이미지 처리 코드는 `LibraryAbsorbed`로 이관
- **어댑터 계층 도입** — `IPrinterManager` 인터페이스와 `MangoPrinterQueryBridge`(약 800줄)로 프린터 조회를 WMI 직접 질의에서 SDK 탐색으로 일원화, 출력 경로 진단 로깅 보강
- **구조 설계서 6종 작성** — `docs/architecture/yegunkim/`에 프로젝트 인벤토리·의존 그래프·프로세스 모델·품질 현황·구조 위험 R1\\~R10(하드코딩 API 키, 뮤텍스 경합, 이중 뷰 계층 등)과 프로젝트별 내부 구조(Application·Usb.Dll·Library·AMPV·Server)를 소스 분석 근거로 문서화
- **인쇄 결함 원인 분석** — 화면의 텍스트 한 줄이 인쇄물에서 누락되는 사용자 제보를 `TextLayerView.UpdatePageView`의 프린터 DC(`GetHdc` 후 `ReleaseHdc` 미호출) GDI 핸들 누수로 진단하고 DC 소유권 모델 수정 계획서 작성
- 후속: 설치 프로젝트(.vdproj) 산출물 목록 재구성, MIP-301 지원의 Mango 포함 여부 확인
## 링크
- 저장소: [github.com/MANGOSLABCoLtd/NemonicBasicWindows](https://github.com/MANGOSLABCoLtd/NemonicBasicWindows) (private)
- 설계서: `docs/architecture/yegunkim/README.md`
---
## 📂 세부 기여 저장소 및 기술 이력 상세 (11개 저장소 연계)
<table header-row="true">
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>**NemonicBasicWindows**</td>
<td>2017.10 – 2022.08</td>
<td>107 Commits, 1 PR</td>
<td>nemonic 메인 Windows 데스크톱 앱 개발 주도, WYSIWYG 편집 엔진, WinForms MVVM 구조 전환, 2026년 .NET 9 및 Mango SDK 현대화 이관</td>
</tr>
<tr>
<td>**NemonicLabelWindows**</td>
<td>2020.07 – 2020.07</td>
<td>48 Commits</td>
<td>라벨 전용 네모닉 Windows 에디터 및 커스텀 인쇄 드라이버 연동 개발</td>
</tr>
<tr>
<td>**Nemonic.Ampv**</td>
<td>2023.06 – 2023.11</td>
<td>12 Commits, 3 PRs</td>
<td>nemonic AMPV(프린터 사용정보 백그라운드 수집 프로세스) 설계, S3/HTTPS 비동기 전송 에이전트 개발</td>
</tr>
<tr>
<td>**NemonicBasicAndroid**</td>
<td>2017.11 – 2018.06</td>
<td>28 Commits</td>
<td>네모닉 1세대 Android 프린터 클라이언트 초기 개발 및 하드웨어 통신 연동</td>
</tr>
<tr>
<td>**NemonicAndroidIntern**</td>
<td>2017.11 – 2018.06</td>
<td>28 Commits</td>
<td>네모닉 모바일 기능 연구 개발 및 인쇄 프로토타입 검증</td>
</tr>
<tr>
<td>**NemonicBasiciOS**</td>
<td>2017.11 – 2022.01</td>
<td>2 Commits</td>
<td>네모닉 1세대 iOS 클라이언트 초기 저장소 코드 등록</td>
</tr>
<tr>
<td>**NemonicPluginAndroid**</td>
<td>2018.08 – 2018.08</td>
<td>1 Commit</td>
<td>Android Print Service Plugin 저장소 초기 구성 참여</td>
</tr>
<tr>
<td>**MemoView**</td>
<td>2022.06 – 2022.06</td>
<td>2 Commits</td>
<td>메모 뷰어 UI 컴포넌트 저장소 초기 구성 참여</td>
</tr>
<tr>
<td>**Firmware**</td>
<td>2022.02 – 2022.02</td>
<td>2 Commits, 1 PR, 1 Issue</td>
<td>펌웨어 저장소 .gitignore 정비 및 형상 관리 보조</td>
</tr>
<tr>
<td>**Firmware.TestUtility**</td>
<td>2026.05 – 2026.05</td>
<td>5 Commits, 1 PR</td>
<td>펌웨어 생산 및 검증용 테스트 유틸리티 리팩토링</td>
</tr>
<tr>
<td>**MIP-301-Centerm-FW-Test**</td>
<td>2026.04 – 2026.05</td>
<td>2 Commits, 8 Issues</td>
<td>MIP-301(Centerm) 프린터 펌웨어 테스트 이슈 8건 등록 및 트래킹</td>
</tr>
</table>
### 기술 이력서 반영 핵심 포인트
- **\[롱텀 소프트웨어 라이프사이클 관리\]** 2017년 첫 상용 릴리스(1.2→1.8)부터 8년 후 2026년 .NET 9 현대화까지 제품의 전 생애주기를 책임지며 지속적인 가치 창출
- **\[레거시 모더니제이션\]** .NET Framework 4.8 레거시 프로젝트 2,000여 줄의 설정을 SDK 스타일로 전환하고 사내 공용 SDK(Mango) 어댑터 패턴으로 일원화
- **\[고난도 결함 진단 및 성능 최적화\]** 사용자 제보 인쇄 누락 장애를 Windows GDI 핸들 누수(DC 소유권 미해제)로 정확히 규명하고 구조적 개선 계획서 및 설계서 6종 작성
### 🔍 Deep Dive: Windows GDI 핸들 누수 결함 진단 및 아키텍처 개선 (김용찬 벤치마킹)
- **문제 상황 (S)**: 화면의 텍스트 한 줄이 실제 열전사 인쇄물에서 간헐적으로 누락되는 결함 제보.
- **원인 규명 (T)**: OS 리소스 모니터링 결과 GDI 오브젝트 수가 10,000개 임계치에 도달함을 확인. `TextLayerView.UpdatePageView`에서 `GetHdc()` 호출 후 `ReleaseHdc()`가 누락되어 Device Context(DC) 핸들이 반환되지 않는 결함 규명.
- **구조적 개선 (A)**: DC 소유권 모델을 `IDisposable` 래퍼로 캡슐화하여 강제 해제 보장, 레거시 프로젝트 전반의 품질 현황 및 구조 위험(R1\~R10)을 분석한 아키텍처 설계서 6종 작성.
- **결과 (R)**: 반복 인쇄 시 발생하던 프린터 DC 핸들 미해제 누수를 차단하고, .NET 9 현대화 마이그레이션 착수 기반 마련.

