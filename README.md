# VPE iOS Native SDK — Demo App

네이버 클라우드 플랫폼 **VPE iOS 네이티브 플레이어 SDK(`VPEPlayer`)** 의 데모 앱입니다.
web `vpe-react-sdk` 의 옵션 JSON 스키마를 그대로 받아 iOS(AVFoundation)에서 재생합니다.

- SDK(바이너리 배포): `https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git`
- 번들 ID: `com.sgrsoft.vpe.native.ios`
- SDK 버전: `1.0.0`

## 요구 사항

- Xcode 15+
- iOS 16.0+
- Swift 5.9+

## SDK 의존성 (바이너리 SwiftPM)

이 데모는 SDK를 **공개 GitHub의 바이너리 Swift Package(XCFramework)** 로 참조합니다.
별도 소스 체크아웃 없이 **데모앱 단독 clone만으로 빌드**됩니다.

```swift
// Package Dependencies
.package(url: "https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git", from: "1.0.0")
```

Xcode에서 추가하려면: **File ▸ Add Package Dependencies…** 에 아래 URL 입력 후 `VPEPlayer` 라이브러리 선택.

```
https://github.com/SGRsoft-Dev/vpe2-ios-native-sdk.git
```

> 이 패키지는 컴파일된 `VPEPlayer.xcframework`(iOS device + simulator)를 GitHub Release로 배포합니다(소스 비공개).

### 로컬 SDK 소스로 개발할 때 (모노레포)

SDK 소스를 함께 수정하려면 로컬 패키지로 전환할 수 있습니다.

```
vpe2-ios/
├── sdk/        ← devtools.ncloud.com/2889160/vpe2-ios-native-sdk.git (소스)
└── demoapp/    ← 이 저장소
```

Xcode → Package Dependencies 에서 원격 패키지를 제거하고 로컬 `../sdk` 를 추가하면 됩니다.

## 실행

```bash
open VPEDemo.xcodeproj
```
스킴 `VPEDemo` 선택 → 시뮬레이터 또는 실제 기기에서 ⌘R.

> ⚠️ **FairPlay DRM 데모는 실기기에서만** 복호화/재생됩니다(시뮬레이터 불가).

## 데모 시나리오

홈(`ContentView`)에서 세 가지 시나리오로 진입합니다.

### 1) 기본 플레이어 구성 (`BasicPlayerView`)
- web SDK와 동일한 **옵션 JSON 그대로 실행** — 따옴표 없는 키 / 후행 콤마 / `//` 주석 등 느슨한(JSON5-ish) 문법 허용.
- Configuration 카드에서 **platform / stage / accessKey** 입력 → "적용"으로 재구성(`.id` 재생성).
- HLS(`.m3u8`) 재생, 플레이리스트(이전/다음 + **종료 시 다음 영상 자동재생**), 자막(VTT/SRT) 토글, 워터마크 등.

### 2) 원격 API 데모 (`RemoteApiPlayerView`)
- `https://vpe.sgrsoft.com/api/playurl?v=1` 에서 **옵션 JSON을 수신** → `VpePlayer` 에 그대로 주입해 재생.

### 3) 원클릭 멀티 DRM (`DrmTestPlayerView`)
- `https://vpe.sgrsoft.com/api/drmTest` 파싱 → **FairPlay(HLS) DRM** 재생.
- NCP Multi-DRM(API Gateway) 인증 헤더(`x-ncp-*`, `x-drm-token`)를 cert/license 요청에 패스스루.
- ⚠️ 실기기 전용.

## SDK 사용 (핵심 API)

```swift
import SwiftUI
import VPEPlayer

// 옵션 딕셔너리
VpePlayer(accessKey: "YOUR_ACCESS_KEY",
          platform: "pub", stage: "real",
          options: ["playlist": [["file": "https://.../index.m3u8"]],
                    "aspectRatio": "16/9", "autostart": true, "muted": true])

// 또는 옵션 JSON 문자열 (web <VpePlayer>와 동일 스키마)
VpePlayer(accessKey: "YOUR_ACCESS_KEY", optionsJSON: jsonString)
```

라이선스 체크 / 옵션 머지 / 풀스크린 / 컨트롤 / 자막 / MA 는 모두 SDK 내부에서 처리됩니다.

## 주요 동작

- **HLS(.m3u8) · MP4 · FairPlay(HLS) DRM** 재생 — 외부 모듈 불필요(순수 AVPlayer).
- **DASH(.mpd)는 미지원** — 재생 시도 시 `E0010` 에러 오버레이로 차단.
- **자막 VTT/SRT** + iOS **접근성 자막 스타일** 연동, 자막 토글(상태 로컬 저장·복원, 기본 OFF).
- **풀스크린** — 디바이스 회전, 비디오는 `objectFit` + `aspectRatio` 유지(크롭 X), 컨트롤 자동 숨김.
- **백그라운드 재생 + PiP**(`allowsPictureInPicture`), **Now Playing**(잠금화면/제어센터 + 원격 명령).
- **화면 캡처/녹화 방지**(`screenRecordingPrevention` → E0014).
- 좌/우 더블탭 ±10초 시킹, 길게 눌러 1.5배속, 아이콘 탭 스케일 피드백.

## 프로젝트 구조

```
demoapp/
├── VPEDemo.xcodeproj
└── VPEDemo/
    ├── VPEDemoApp.swift        # @main + AppDelegate(회전 지원 마스크)
    ├── ContentView.swift       # 홈 (NavigationStack → 3개 시나리오)
    ├── BasicPlayerView.swift   # 옵션 JSON 기반 플레이어 + Configuration/App Info 카드
    ├── RemoteApiPlayerView.swift  # playurl API 옵션 수신 → 재생
    ├── DrmTestPlayerView.swift  # drmTest API → FairPlay DRM 재생
    ├── DemoCard.swift          # 카드/필드/버튼 데모 UI 컴포넌트
    ├── DemoTheme.swift         # 다크 테마 색상 토큰
    ├── Assets.xcassets
    └── Info.plist
```

## Info.plist 설정 (포함됨)

- `UIBackgroundModes` = `audio` — 백그라운드 오디오 / PiP
- `NSAppTransportSecurity` → `NSExceptionDomains` `naverncp.com` — `http://` 사이드카 자막 로드 허용
- `UISupportedInterfaceOrientations` (iPhone) — portrait + landscape (풀스크린 회전)
- 디바이스 회전 풀스크린: `AppDelegate.supportedInterfaceOrientationsFor` → `OrientationManager.shared.currentMask`

## 라이선스

사내 프로젝트 — SGRsoft / 네이버 클라우드 플랫폼.
