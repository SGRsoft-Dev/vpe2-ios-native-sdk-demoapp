import SwiftUI
import UIKit
import VPEPlayer

enum Platform: String, CaseIterable { case pub, gov }
enum Stage: String, CaseIterable { case real, beta }

/// "기본 플레이어 구성" — vpe-react-sdk 옵션 JSON을 그대로 받아 실행.
struct BasicPlayerView: View {

    // MARK: - 입력 JSON (web SDK와 동일 스키마)

    private static let optionsJSON: String = """
    {
      "playlist": [
        {
          "file": "https://u6dwfh2w5883.edge.naverncp.com/hls/-EQTX8kk3dFTfezHSE0rcg__/vodstation/vod-abr-test/j5IXBfIJ83893893_1080p_,AVC_SD_1Pass_30fps_1,AVC_HD_1Pass_30fps,AVC_FHD_1Pass_30fps,.mp4.smil/master.m3u8",
          "poster": "https://tkmenfxu2702.edge.naverncp.com/profile/202605/25e7fe682c76cbbb31e7e6fc79a653ac.png",
          "description": {
            "created_at": "Wed Jul 13 2022 00:00:00 GMT+0900 (한국 표준시)",
            "profile_image": "https://tkmenfxu2702.edge.naverncp.com/profile/202511/cf38c0603c57faacd99cbe6d967c38b3.png",
            "profile_name": "네이버클라우드",
            "title": "1편 — 네이버클라우드 소개"
          },
                    srt: [
                        {
                            id: "ko",
                            file: "http://player.vpe.naverncp.com/srt/ncp_overview_script_kr_v2.srt",
                            label: "한국어",
                            default: true, 
                        },
                        {
                            id: "en",
                            file: "http://player.vpe.naverncp.com/srt/ncp_overview_script_en_v2.srt",
                            label: "영어",
                        },
                    ],
        
        },
        {
          "file": "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8",
          "poster": "https://2ardrvaj2252.edge.naverncp.com/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_01.jpg",
          "description": {
            "created_at": "Wed Jul 13 2022 00:00:00 GMT+0900 (한국 표준시)",
            "profile_image": "https://tkmenfxu2702.edge.naverncp.com/profile/202511/cf38c0603c57faacd99cbe6d967c38b3.png",
            "profile_name": "네이버클라우드",
            "title": "2편 — 두 번째 에피소드"
          }
        },
        
      ],
      "autostart": true,
      "muted": false,
      "aspectRatio": "16/9",
      "objectFit": "contain",
      "controls": true,
      "keyboardShortcut": true,
      "seekingPreview": true,
      "touchGestures": true,
      "startMutedInfoNotVisible": false,
      "lang": "auto",
      "ui": "auto",
      "progressBarColor": "#00ff11",
      "controlActiveTime": 3000,
      "autoPause": false,
      "repeat": false,
      "lowLatencyMode": false,
      "iosFullscreenNativeMode": true,
      "descriptionNotVisible": false,
      "visibleWatermark": false,
      "autoPIP":true,
      "controlBtn": {
        "play": true,
        "fullscreen": true,
        "progressBar": true,
        "volume": true,
        "times": true,
        "pictureInPicture": true,
        "setting": true,
        "subtitle": true
      },
      "layout": null
    }
    """

    // MARK: - State

    @StateObject private var controller: VPEPlayerController
    private let playlistItems: [PlaylistItem]

    @State private var platform: Platform = .pub
    @State private var stage: Stage = .real
    @State private var licenseKey: String = "baebffcc0054efdc485877cff0e483b1"
    @State private var showingSettings: Bool = false
    @State private var parseError: String?

    // MARK: - Init: JSON 디코드 + controller 셋업

    init() {
        let input: PlayerInput
        var parseError: String?
        do {
            input = try PlayerInput.from(jsonString: Self.optionsJSON)
        } catch {
            input = PlayerInput(playlist: [], options: PlayerOptions())
            parseError = String(describing: error)
        }
        _controller = StateObject(wrappedValue: VPEPlayerController(
            scopeID: "demo-main",
            options: input.options
        ))
        playlistItems = input.playlist
        _parseError = State(initialValue: parseError)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            // 메인 콘텐츠 (인라인 플레이어 + 카드)
            ZStack(alignment: .top) {
                DemoTheme.appBackground.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        VPEPlayerView(controller: controller)
                            .aspectRatio(16/9, contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .background(Color.black)

                        VStack(spacing: 16) {
                            if let err = parseError {
                                errorCard(err)
                            }
                            jsonInfoCard
                            appInfoCard
                            configurationCard
                            playerControlsCard
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    }
                }
                .scrollIndicators(.hidden)
            }

            // 풀스크린 overlay — 같은 ZStack subtree라 host view가 reparent됨 (재생성 X)
            // .ignoresSafeArea는 컨테이너 내부(배경/비디오)에서만 적용 → 컨트롤은 safe area 안
            if controller.isFullscreen {
                VPEFullscreenContainer(controller: controller)
                    .zIndex(999)
            }
        }
        .navigationTitle("기본 플레이어 구성")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(controller.isFullscreen ? .hidden : .visible, for: .navigationBar)
        .onAppear {
            controller.loadPlaylist(playlistItems)
        }
        .sheet(isPresented: $showingSettings) {
            SettingModal(controller: controller)
                .presentationDetents([.height(360), .medium])
                .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Cards

    private var jsonInfoCard: some View {
        DemoCard(icon: "curlybraces", title: "JSON 옵션 (적용됨)") {
            VStack(alignment: .leading, spacing: 8) {
                appliedRow("playlist", "\(controller.playIndex + 1) / \(controller.playlist.count)")
                appliedRow("source", controller.currentItem?.title ?? "—")
                appliedRow("profile", controller.currentItem?.profileName ?? "—")
                appliedRow("created", controller.currentItem?.createdAt.map(format) ?? "—")
                appliedRow("progressBar", controller.options.progressBarColor ?? "default")
                appliedRow("autostart", controller.options.autostart ? "true" : "false")
                appliedRow("muted", controller.options.muted ? "true" : "false")
                appliedRow("controlActiveTime",
                          String(format: "%.1fs", controller.options.controlActiveTime))
                appliedRow("ui", controller.options.ui.rawValue)
                appliedRow("watermark", controller.options.visibleWatermark ? "on" : "off")
            }
        }
    }

    private func errorCard(_ err: String) -> some View {
        DemoCard(icon: "exclamationmark.triangle.fill", title: "JSON 파싱 오류") {
            Text(err)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var appInfoCard: some View {
        DemoCard(icon: "info.circle", title: "App Info") {
            DemoLabeledField(label: "Bundle Identifier") {
                HStack(spacing: 10) {
                    Text(Bundle.main.bundleIdentifier ?? "—")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(DemoTheme.textPrimary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(DemoTheme.fieldBackground)
                        )

                    Button {
                        UIPasteboard.general.string = Bundle.main.bundleIdentifier
                    } label: {
                        Text("복사")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DemoTheme.textPrimary)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(DemoTheme.accent)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var configurationCard: some View {
        DemoCard(icon: "slider.horizontal.3", title: "Configuration") {
            VStack(alignment: .leading, spacing: 18) {
                DemoLabeledField(label: "Platform") {
                    DemoSegmented(
                        options: [(Platform.pub, "pub"), (Platform.gov, "gov")],
                        selection: $platform
                    )
                }
                DemoLabeledField(label: "Stage") {
                    DemoSegmented(
                        options: [(Stage.real, "real"), (Stage.beta, "beta")],
                        selection: $stage
                    )
                }
                DemoLabeledField(label: "License Key (AccessKey)") {
                    DemoFieldWithAction(
                        text: $licenseKey,
                        actionLabel: "적용",
                        onAction: { /* TODO core wire */ }
                    )
                }
            }
        }
    }

    private var playerControlsCard: some View {
        DemoCard(icon: "gamecontroller.fill", title: "Player Controls") {
            VStack(spacing: 12) {
                DemoActionButton(icon: "play.circle.fill", label: "재생") {
                    controller.play()
                }
                DemoActionButton(icon: "pause.circle.fill", label: "일시정지") {
                    controller.pause()
                }
                DemoActionButton(
                    icon: controller.avPlayer.isMuted
                        ? "speaker.slash.circle.fill"
                        : "speaker.wave.2.circle.fill",
                    label: controller.avPlayer.isMuted ? "음소거 해제" : "음소거"
                ) {
                    controller.setMuted(!controller.avPlayer.isMuted)
                }
                DemoActionButton(icon: "gobackward.10", label: "10초 뒤로") {
                    controller.seek(to: max(0, controller.currentTime - 10))
                }
                DemoActionButton(icon: "goforward.10", label: "10초 앞으로") {
                    controller.seek(to: min(controller.duration, controller.currentTime + 10))
                }
                DemoActionButton(icon: "forward.end.fill", label: "끝으로 (replay 테스트)") {
                    if controller.duration > 1 {
                        controller.seek(to: controller.duration - 1)
                    }
                }
                DemoActionButton(icon: "gearshape.fill", label: "설정 메뉴 열기") {
                    showingSettings = true
                }
                DemoActionButton(icon: "arrow.up.left.and.arrow.down.right", label: "풀스크린 진입") {
                    controller.enterFullscreen()
                }
            }
        }
    }

    // MARK: - Helpers

    private func appliedRow(_ k: String, _ v: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(k)
                .frame(width: 130, alignment: .leading)
                .foregroundStyle(DemoTheme.textTertiary)
            Text(v)
                .foregroundStyle(DemoTheme.textPrimary)
        }
        .font(.system(size: 12, design: .monospaced))
    }

    private func format(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy. M. d."
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack { BasicPlayerView() }
}
