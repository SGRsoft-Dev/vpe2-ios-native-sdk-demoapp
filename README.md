# VPE iOS Native SDK — Demo App

네이버 클라우드 플랫폼 **VPE iOS 네이티브 플레이어 SDK(`VPEPlayer`)** 의 데모 앱입니다.
웹 `vpe-react-sdk` 의 옵션 스키마(딕셔너리/JSON)를 그대로 받아 iOS(AVFoundation)에서 재생합니다.

- SDK(바이너리 배포): `https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git`
- 번들 ID: `com.sgrsoft.vpe.native.ios`
- SDK 버전: **1.0.6**

## 요구 사항

- Xcode 15+ / iOS 16.0+ / Swift 5.9+

## SDK 참조 방식 (바이너리 기본 / 로컬 선택)

기본은 **공개 GitHub의 바이너리 Swift Package(XCFramework, 1.0.6)** 참조 → 데모앱 단독 clone만으로 빌드됩니다.

```swift
.package(url: "https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git", from: "1.0.6")
```

SDK 소스를 함께 수정하며 개발하려면 로컬 `../sdk` 로 전환할 수 있습니다:

```bash
cp .local.env.example .local.env   # .local.env 존재 → 로컬(../sdk) 참조
scripts/select-sdk.sh              # 모드에 맞게 pbxproj 패키지 참조 전환
# 강제: scripts/select-sdk.sh local | remote
```
- `.local.env` 가 **있으면 로컬(`../sdk`)**, **없으면 바이너리 패키지**. `.local.env` 는 .gitignore 로 제외(커밋 기본값 = 바이너리).

## 실행

```bash
open VPEDemo.xcodeproj
```
스킴 `VPEDemo` 선택 → 시뮬레이터 또는 실제 기기에서 ⌘R.

> ⚠️ **FairPlay DRM / PiP / 화면녹화방지 / Now Playing** 은 실기기에서만 정상 동작합니다(시뮬레이터 제한).

## 데모 시나리오 (홈 `ContentView`)

| 메뉴 | View | 설명 |
|---|---|---|
| 기본 플레이어 구성 | `BasicPlayerDictView` | 옵션을 **Swift 딕셔너리**로 직접 구성 |
| 기본 플레이어 구성 (JSON) | `BasicPlayerView` | 옵션 **JSON 문자열**(web 스키마) + Configuration 카드 |
| 원격 API 데모 | `RemoteApiPlayerView` | `playUrl` API에서 옵션 JSON 수신 → 재생 |
| 원클릭 멀티 DRM | `DrmTestPlayerView` | `drmTest` API → NCP FairPlay(HLS) DRM (실기기) |
| PallyCon DRM | `DrmTestPlayerView` | `drmTestPallycon` API → PallyCon FairPlay (실기기) |
| OTT 기능 | `OTTPlayerView` | 인트로/오프닝/엔딩 스킵 + 연령등급/콘텐츠 경고 고지 + 커스텀 레이아웃 |
| 라이브 스트림 | `LiveStreamPlayerView` | Mux HLS 라이브 · duration 자동감지 → LIVE 레이아웃 |
| ScreenRecordingPrevention | `ScreenRecordingPreventionView` | 화면 녹화/캡처 감지 차단(E0014) |
| Picture in Picture | `PictureInPictureView` | 백그라운드 자동 PiP + 백그라운드 재생 |
| Now Playing | `NowPlayingView` | 잠금화면/제어센터 미니플레이어 + 원격 명령 |
| 워터마크 | `WatermarkPlayerView` | 랜덤 이동 / 고정 위치 워터마크 (web 옵션) |
| 메서드 제어 | `ImperativeControlView` | 컨트롤러 직접 보유 + 외부 버튼으로 SDK 메서드 호출 |
| VTT 자막 | `VttSubtitleView` | `playlist[].vtt` 다국어 사이드카 |
| SRT 자막 | `SrtSubtitleView` | `playlist[].srt` 다국어 사이드카 |

## SDK 사용 (핵심 API)

```swift
import SwiftUI
import VPEPlayer

// 1) 간편 컴포넌트 — 딕셔너리
VpePlayer(accessKey: "YOUR_ACCESS_KEY", platform: "pub", stage: "real",
          options: ["playlist": [["file": "https://.../index.m3u8"]],
                    "aspectRatio": "16:9", "autostart": true])

// 2) 간편 컴포넌트 — JSON 문자열 (web 스키마)
VpePlayer(accessKey: "YOUR_ACCESS_KEY", optionsJSON: jsonString)

// 3) 컨트롤러 직접 보유 — 외부 메서드 제어 (커스텀 UI)
@StateObject var player = VPEPlayerController(options: [...], accessKey: "...", platform: "pub", stage: "real")
VPEPlayerView(controller: player, showsBuiltinControls: false)
// player.play() / pause() / seek(to:) / toggleFullscreen() ...
```

라이선스 체크 / 옵션 머지 / 풀스크린 / 컨트롤 / 자막 / MA 는 모두 SDK 내부에서 처리됩니다.
전체 옵션·메서드 레퍼런스: SDK 저장소의 `llms.txt` 참고.

## 주요 동작

- **HLS(.m3u8) · MP4 · FairPlay(HLS) DRM** 재생 (순수 AVPlayer). **DASH(.mpd) 미지원**(E0010).
- 자막 **VTT/SRT** + iOS **접근성 자막 스타일** 연동 (기본 OFF, 토글 로컬 저장·복원).
- **OTT**: intro/opening/ending 스킵 버튼(우상단), ageRating/contentWarnings 고지(3초 후 1회).
- **라이브**: duration 무한 자동감지 → LIVE 레이아웃(시간 'LIVE', SeekBar 숨김).
- **워터마크**: `watermarkConfig`(randPosition 주기 이동 / x·y(%) 고정 / opacity).
- 풀스크린(회전, objectFit+aspectRatio 유지), PiP/백그라운드, Now Playing, 화면녹화방지.
- 좌/우 더블탭 ±10초 시킹, 길게 눌러 1.5배속.

## 프로젝트 구조

```
demoapp/
├── scripts/select-sdk.sh       # 로컬/바이너리 SDK 참조 전환
├── .local.env.example          # 로컬 참조용 (복사 → .local.env)
├── VPEDemo.xcodeproj
└── VPEDemo/
    ├── VPEDemoApp.swift         # @main + AppDelegate(회전 마스크)
    ├── ContentView.swift        # 홈 (NavigationStack → 14개 시나리오)
    ├── *PlayerView / *SubtitleView / ...  # 시나리오별 View
    ├── DemoCard.swift / DemoTheme.swift   # 데모 UI 컴포넌트/테마
    └── Assets.xcassets / Info.plist
```

## Info.plist 설정 (포함됨)

- `UIBackgroundModes` = `audio` — 백그라운드 오디오 / PiP
- `NSAppTransportSecurity` → `naverncp.com` 예외 — `http://` 사이드카 자막 허용
- `UISupportedInterfaceOrientations` (iPhone) — portrait + landscape (풀스크린 회전)
- `AppDelegate.supportedInterfaceOrientationsFor` → `OrientationManager.shared.currentMask` (풀스크린 회전 필수)

## 라이선스

사내 프로젝트 — SGRsoft / 네이버 클라우드 플랫폼.
