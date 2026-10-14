# 🏷️ [하드웨어 연동 앱] FINECUBE 컬러 라벨 앱 & BLE 통신 경합 해소 (Lithium)

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🏷️ [하드웨어 연동 앱] FINECUBE 컬러 라벨 앱 & BLE 통신 경합 해소 (Lithium)](https://app.notion.com/p/3dd475218675813aa4cdfa7fca9e534a)  
> **최종 동기화 일시**: 2026-10-14

---

<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2022.01 – 2025.07</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>망고슬래브 · 유지보수·릴리스 담당</td>
</tr>
<tr>
<td>기여</td>
<td>커밋 10 / 40</td>
</tr>
<tr>
<td>상태</td>
<td>Monolith의 Lithium 하위 시스템으로 이관 완료</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`Xamarin.Forms` `MvvmCross` `SkiaSharp` `EF Core` `SQLite` `BLE`</td>
</tr>
</table>
## 개요
라벨 프린터 **FINECUBE**의 Android·iOS 앱입니다. 템플릿 기반 라벨 편집(텍스트·바코드·클립아트·이미지 레이어, Undo/Redo, 핀치·드래그), BLE 프린터 연결·배터리·잉크 상태 표시, 다국어(한·영·일·러시아어·중국어 대만 번체) 지원을 제공합니다. 이후 Monolith의 Lithium 하위 시스템으로 이관되었습니다.
## 기술 스택
<table fit-page-width="true" header-row="true">
<tr>
<td>영역</td>
<td>구성</td>
</tr>
<tr>
<td>앱</td>
<td>Xamarin.Forms + MvvmCross (netstandard2.1), Android / iOS 플랫폼 프로젝트</td>
</tr>
<tr>
<td>렌더링</td>
<td>SkiaSharp 기반 캔버스 편집기, SVG 클립아트</td>
</tr>
<tr>
<td>바코드</td>
<td>[ZXing.Net.Mobile](http://ZXing.Net.Mobile)</td>
</tr>
<tr>
<td>데이터</td>
<td>EF Core + SQLite, 별도 Migrations 콘솔 프로젝트로 스키마 이력 관리</td>
</tr>
<tr>
<td>프린터 SDK</td>
<td>Android/iOS 네이티브 프린터 SDK 바인딩(Mango.Print.Finecube.\\*)</td>
</tr>
</table>
## 구성 요소
- **라벨 편집기** — 텍스트·바코드·클립아트·이미지 레이어, Undo/Redo, 핀치·드래그 조작
- **프린터 연결** — BLE 연결, 배터리·잉크 상태 표시, 자동 연결
- **공용 라이브러리** — Mango.\\* (Forms·ViewModels·Repo·Barcode·Svg·Print)
- **다국어** — 한·영·일·대만·러시아어
## 주요 작업
- Android targetSdk 33(2022.10) → 34(2025.07) 상향과 릴리스 서명·AAB 배포
- 프린터 상태 갱신 작업 간 경합 해소, 프린터 자동 연결 예외 처리
## 링크
- 저장소: [github.com/MANGOSLABCoLtd/Lithium](https://github.com/MANGOSLABCoLtd/Lithium) (private)
- 이관 대상: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>
---
## 📂 세부 기여 저장소 및 기술 이력 상세
<table header-row="true">
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
<td>FINECUBE 라벨 프린터 모바일 앱 유지보수 및 릴리스 전담, BLE 동기화 작업 경합 해소, targetSdk 33→34 마이그레이션, Monolith 이관</td>
</tr>
<tr>
<td>**Sulfur**</td>
<td>2022.01 – 2022.01</td>
<td>8 Commits, 1 PR</td>
<td>Aesty 무선 헤어 스트레이트너 디바이스 관리 모바일 앱 초기 아키텍처 구축 및 BLE 주변기기 통신 라이프사이클 설계</td>
</tr>
<tr>
<td>**Mangoslab.Drawing**</td>
<td>2021.12 – 2025.06</td>
<td>71 Commits, 26 PRs, 29 Issues</td>
<td>SkiaSharp 기반 모바일 캔버스 레이어 편집기(텍스트·바코드·클립아트, Undo/Redo, 터치 핀치/드래그) 코어 라이브러리 개발</td>
</tr>
</table>
### 기술 이력서 반영 핵심 포인트
- **\[모바일 앱 라이프사이클 관리\]** Xamarin.Forms + MvvmCross 기반 FINECUBE 앱의 장기 운영 및 Google Play 정책 변경(targetSdk 34) 대응 AAB 배포 완료
- **\[하드웨어 통신 안정화\]** Bluetooth LE 연결 시 배터리/잉크 상태 조회 작업 간 경합 상태(Race Condition)를 해결하고 비동기 재시도 파이프라인 구축
- **\[그래픽스 코어 모듈화\]** SkiaSharp 기반 2D 캔버스 렌더러를 공통 모듈화하여 다중 모바일 프로젝트 간 재사용성 확보

