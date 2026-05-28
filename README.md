# VPE iOS Native SDK — Demo App

네이버 클라우드 플랫폼 **VPE iOS 네이티브 플레이어 SDK(`VPEPlayer`)** 의 데모 앱입니다.
[vpe-react-sdk](https://github.com/SGRsoft-Dev)의 옵션 JSON 스키마를 그대로 받아 iOS에서 재생합니다.

- SDK 저장소: `https://devtools.ncloud.com/2889160/vpe2-ios-native-sdk.git`
- 번들 ID: `com.sgrsoft.vpe.native.ios`
- 버전: `0.1.0`

## 요구 사항

- Xcode 15+
- iOS 16.0+
- Swift 5.x

## SDK 의존성 (중요)

이 데모는 SDK를 **로컬 Swift Package(`../sdk`)** 로 참조합니다
(`XCLocalSwiftPackageReference "../sdk"` → product `VPEPlayer`).

따라서 **데모앱 단독 clone만으로는 빌드되지 않습니다.** 아래 둘 중 하나로 맞춰주세요.

**① SDK를 형제 폴더로 함께 배치 (권장)**
```
vpe2-ios/
├── sdk/        ← devtools.ncloud.com/.../vpe2-ios-native-sdk.git
└── demoapp/    ← 이 저장소
```
```bash
mkdir vpe2-ios && cd vpe2-ios
git clone https://devtools.ncloud.com/2889160/vpe2-ios-native-sdk.git sdk
git clone https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk-demoapp.git demoapp
open demoapp/VPEDemo.xcodeproj
```

**② 원격 SwiftPM 패키지로 전환**
Xcode → Project → Package Dependencies 에서 로컬 `../sdk` 참조를 제거하고
SDK git URL(위 ncloud 주소)을 추가해도 됩니다.

## 실행

```bash
open VPEDemo.xcodeproj
```
Xcode에서 스킴 `VPEDemo` 선택 → 시뮬레이터 또는 실제 기기에서 ⌘R.

## 데모가 보여주는 것

- **옵션 JSON 그대로 실행** — `BasicPlayerView`에 web SDK와 동일한 옵션 JSON을 넣어 구동.
  따옴표 없는 키 / 후행 콤마 / `//` 주석 등 느슨한(JSON5-ish) 문법도 허용.
- **HLS 재생** (`.m3u8`, AVPlayer)
- **플레이리스트** — 이전/다음 이동, **재생 완료 시 다음 영상 자동 이어재생**, `repeat` 루프
- **자막 VTT / SRT** — 외부 사이드카 URL 다운로드·파싱, `default:true` 자동 활성,
  자막 버튼 토글, 설정 모달에서 언어 선택
- **iOS 접근성 자막 스타일 연동** — 설정 > 손쉬운 사용 > 자막 및 캡션 스타일 반영
- **풀스크린** — 디바이스 자동 회전, 비디오는 `objectFit` + `aspectRatio` 유지(크롭 X)
- **컨트롤바** — `controlActiveTime` 자동 숨김, 탭 토글, 좌/우 더블탭 ±10초 시킹,
  아이콘 버튼 탭 스케일 피드백, 초기 진입 시 컨트롤 숨김
- **백그라운드 재생 + autoPIP** — 앱 백그라운드 전환 시 옵션에 따라 PiP 자동 진입
- **Now Playing** — 잠금화면 / 제어센터 미니플레이어 + 원격 명령(재생/일시정지/스킵/트랙 이동)
- **카드형 데모 UI** — App Info / Configuration / Player Controls

## 프로젝트 구조

```
demoapp/
├── VPEDemo.xcodeproj
└── VPEDemo/
    ├── VPEDemoApp.swift      # @main + AppDelegate(회전 지원 마스크)
    ├── ContentView.swift     # 홈 (NavigationStack → "기본 플레이어 구성")
    ├── BasicPlayerView.swift # 옵션 JSON 기반 플레이어 데모 + 카드 UI
    ├── DemoCard.swift         # 카드/필드/버튼 등 데모 UI 컴포넌트
    ├── DemoTheme.swift        # 다크 테마 색상 토큰
    ├── Assets.xcassets
    └── Info.plist
```

## Info.plist 설정

데모가 동작하려면 아래 키가 필요합니다 (이미 포함됨):

- `UIBackgroundModes` = `audio` — 백그라운드 오디오 재생 / PiP
- `NSAppTransportSecurity` → `NSExceptionDomains` `naverncp.com`
  (`NSExceptionAllowsInsecureHTTPLoads`) — `http://` 사이드카 자막 로드 허용
- `UISupportedInterfaceOrientations` (iPhone) — portrait + landscape (풀스크린 회전)

## 옵션 JSON 변경

`VPEDemo/BasicPlayerView.swift` 상단의 `optionsJSON` 문자열을 수정하면
playlist / 자막 / 컨트롤 버튼 / 워터마크 등 동작이 즉시 바뀝니다.
스키마는 vpe-react-sdk의 `llms.txt` 옵션 스펙과 호환됩니다
(`iosFullscreenNativeMode`만 미지원).

## 라이선스

사내 프로젝트 — SGRsoft / 네이버 클라우드 플랫폼.
