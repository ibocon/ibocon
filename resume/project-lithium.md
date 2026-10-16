# 🏷️ 08.02. 모바일 라벨 편집기 앱 유지보수 및 SDK 34 현대화

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🏷️ 08.02. 모바일 라벨 편집기 앱 유지보수 및 SDK 34 현대화](https://app.notion.com/p/3dd475218675813aa4cdfa7fca9e534a)  
> **최종 동기화 일시**: 2026-10-16

---

<callout icon="🏷️" color="gray_bg">
	**핵심 요약**: 상용 라벨 프린터 **FINECUBE**의 Android · iOS 앱(`Lithium`)입니다. **SkiaSharp 기반 터치 캔버스 라벨 편집기(텍스트·바코드·클립아트·이미지 레이어, Undo/Redo, 핀치·드래그)**, **Android 14(`targetSdk 34`) 스토어 정책 대응 및 AAB 릴리스**, 다국어(한·영·일·대만 번체·러시아어) 지원을 담당했으며 현재 `Monolith`의 `Lithium` 하위 시스템으로 통합되었습니다. *(※ BLE 프로토콜 스택 상세는 `10. 시스템 프로그래밍` 도메인에서 다룹니다.)*
</callout>
<table fit-page-width="true" header-column="true">
<colgroup>
<col width="140">
<col width="560">
</colgroup>
<tr>
<td>관련 프로젝트</td>
<td>`Lithium` (상용 **FINECUBE** Android · iOS 앱 · `Mangoslab.Drawing` SkiaSharp 캔버스 코어 · `Monolith/src/Lithium`)</td>
</tr>
<tr>
<td>기간</td>
<td>2022.01 – 2025.07</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>망고슬래브 · 모바일 앱 유지보수·릴리스 및 SkiaSharp 캔버스 코어 개발</td>
</tr>
<tr>
<td>기여</td>
<td>Lithium (10 Commits, 7 PRs) · Mangoslab.Drawing 캔버스 코어 (71 Commits, 26 PRs) · Sulfur (8 Commits, 1 PR)</td>
</tr>
<tr>
<td>상태</td>
<td>Google Play / App Store 상용 운영 · `Monolith`의 `Lithium` 하위 시스템으로 이관 완료</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`Xamarin.Forms` `MvvmCross` `SkiaSharp` `ZXing.Net.Mobile` `EF Core` `SQLite` `Android targetSdk 34` `iOS`</td>
</tr>
</table>
---
## 1. FINECUBE(`Lithium`) 모바일 앱 및 `SkiaSharp` 캔버스 아키텍처 다이어그램
- **1. 2D 캔버스 & UI (`Mangoslab.Drawing`)**: `Xamarin.Forms` + `MvvmCross` 크로스플랫폼 ViewModel · `SkiaSharp` 다중 레이어 편집기 (텍스트·바코드·SVG·핀치/드래그·Undo/Redo)
- **2. 로컬 데이터 & 프린터 브릿지**: `EF Core` + `SQLite` (별도 Migrations 프로젝트로 스키마 관리) · `Mango.Print.Finecube.*` 배터리·카트리지 상태 폴링 동기화
- **3. 모바일 플랫폼 호스트 & 스토어 릴리스**: **Android** (`targetSdk 33 → 34` 상향 및 AAB 서명 배포) · **iOS** (App Store 상용 배포 및 5개국어 리소스 지원)
---
## 2. 기술 스택 및 구성 요소 매트릭스
<table fit-page-width="true" header-row="true">
<tr>
<td>영역</td>
<td>핵심 기술 구성</td>
<td>설계 책임 및 구현 내용</td>
</tr>
<tr>
<td>**모바일 앱 프레임워크**</td>
<td>`Xamarin.Forms` + `MvvmCross` (`netstandard2.1`)</td>
<td>Android / iOS 크로스플랫폼 ViewModel 상태 공유, 네비게이션 및 다국어(한·영·일·대만·러시아어) 제공</td>
</tr>
<tr>
<td>**2D 그래픽스 편집기**</td>
<td>`SkiaSharp` (`Mangoslab.Drawing`) + `SVG` + `ZXing.Net.Mobile`</td>
<td>텍스트·바코드·QR·SVG 클립아트·이미지 다중 레이어 합성, 멀티터치 핀치 줌/회전/드래그 및 Command 기반 Undo/Redo</td>
</tr>
<tr>
<td>**로컬 데이터 영속성**</td>
<td>`EF Core` + `SQLite`</td>
<td>사용자 라벨 문서 및 최근 사용 템플릿 저장, 별도 Migrations 콘솔 프로젝트로 모바일 DB 스키마 이력 관리</td>
</tr>
<tr>
<td>**프린터 연동 & 배포**</td>
<td>`Mango.Print.Finecube.*` · `Android AAB`</td>
<td>배터리·카트리지/잉크 상태 폴링 작업 간 경합 제어, Android `targetSdk 33 → 34` 상향 및 스토어 릴리스 서명</td>
</tr>
</table>
---
## 3. 대표 모바일 엔지니어링 문제 해결 사례 (Problem · Action · Result)
- **[사례 1] Google Play 스토어 정책 변경에 따른 Android 14(`targetSdk 34`) 마이그레이션 및 릴리스**
	- **문제(Problem)**: Google Play의 `targetSdkVersion 34` 의무화로 인해 기존 SDK 타겟 및 권한 설정 상태로는 신규 버전 AAB 업로드와 최신 Android 기기 설치가 제한됨.
	- **해결(Action)**: Android 프로젝트의 `targetSdk`를 33에서 34로 단계적으로 상향하고, OS 버전에 따른 런타임 권한 분기 및 릴리스 키스토어 서명·AAB 패키징 파이프라인을 정비함.
	- **결과(Result)**: 스토어 정책 기한 내 심사 통과 및 상용 배포 지속성 확보.
- **[사례 2] SkiaSharp 기반 2D 터치 캔버스 편집기(`Mangoslab.Drawing`) 모듈화 및 상태 폴링 경합 해소**
	- **문제(Problem)**: 모바일 화면에서 다중 객체(텍스트, 바코드, 클립아트)를 터치로 조작할 때 좌표 변환과 Undo/Redo 이력 관리가 뷰 코드에 섞이면 유지보수가 어렵고, 프린터 배터리·잉크 상태 주기적 조회와 인쇄 명령이 겹칠 때 경합(Race Condition)이 발생함.
	- **해결(Action)**: `SkiaSharp` 레이어 렌더링·히트 테스트·핀치/드래그 변환 행렬을 `Mangoslab.Drawing`(71 Commits, 26 PRs) 코어 라이브러리로 분리하고, 프린터 상태 갱신 작업 간 동기화 락과 자동 연결 예외 처리를 보강함.
	- **결과(Result)**: 캔버스 편집 엔진의 재사용성을 확보하고 프린터 연결 중 간헐적 상태 조회 충돌을 제거.
---
## 4. 세부 기여 저장소 및 기술 이력 상세
<table fit-page-width="true" header-row="true">
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>**Lithium**</td>
<td>2021.11 – 2025.07</td>
<td>10 Commits, 7 PRs, 8 Issues</td>
<td>FINECUBE 라벨 프린터 모바일 앱 유지보수 및 릴리스 전담, 상태 조회 작업 경합 해소, targetSdk 33→34 마이그레이션, Monolith 이관</td>
</tr>
<tr>
<td>**Mangoslab.Drawing**</td>
<td>2021.12 – 2025.06</td>
<td>71 Commits, 26 PRs, 29 Issues</td>
<td>SkiaSharp 기반 모바일 캔버스 레이어 편집기(텍스트·바코드·클립아트, Undo/Redo, 터치 핀치/드래그) 코어 라이브러리 개발</td>
</tr>
<tr>
<td>**Sulfur**</td>
<td>2022.01 – 2022.01</td>
<td>8 Commits, 1 PR</td>
<td>무선 디바이스 관리 모바일 앱 초기 아키텍처 구축 및 주변기기 통신 라이프사이클 설계</td>
</tr>
</table>
- 이관 대상 모노레포: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>
- 하드웨어 통신 SDK (`Mango & Garden.Bluetooth`): <mention-page url="https://app.notion.com/p/3f94752186758193b0abcf62be42f644"/>

