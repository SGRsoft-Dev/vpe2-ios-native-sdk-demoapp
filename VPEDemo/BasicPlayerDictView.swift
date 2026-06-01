import SwiftUI
import UIKit
import VPEPlayer

/// "기본 플레이어 구성" — 옵션 JSON 문자열이 아니라 **Swift 딕셔너리(`[String: Any]`)** 로
/// 옵션을 직접 구성해 `VpePlayer(options:)` 로 전달하는 예시.
/// (JSON 버전은 `BasicPlayerView` — "기본 플레이어 구성 (JSON)")
struct BasicPlayerDictView: View {

    // MARK: - 입력 옵션 (딕셔너리 직접 구성)

    private static let options: [String: Any] = [
        "autostart": true,
        "autoPause": false,
        "allowsPictureInPicture": true,
        "enableNowPlayingPlaybackState": true,
        "screenRecordingPrevention": true,
        "aspectRatio": "16:9",
        "objectFit": "contain",
        "playlist": [
            [
                "file": "https://u6dwfh2w5883.edge.naverncp.com/hls/-EQTX8kk3dFTfezHSE0rcg__/vodstation/vod-abr-test/j5IXBfIJ83893893_1080p_,AVC_SD_1Pass_30fps_1,AVC_HD_1Pass_30fps,AVC_FHD_1Pass_30fps,.mp4.smil/master.m3u8",
                "poster": "https://tkmenfxu2702.edge.naverncp.com/profile/202605/25e7fe682c76cbbb31e7e6fc79a653ac.png",
                "description": [
                    "title": "1편 — 네이버클라우드 소개",
                    "profile_name": "네이버클라우드",
                    "profile_image": "https://tkmenfxu2702.edge.naverncp.com/profile/202511/cf38c0603c57faacd99cbe6d967c38b3.png",
                    "created_at": "Wed Jul 13 2022 00:00:00 GMT+0900 (한국 표준시)"
                ],
                "srt": [
                    ["id": "ko", "file": "http://player.vpe.naverncp.com/srt/ncp_overview_script_kr_v2.srt", "label": "한국어", "default": true],
                    ["id": "en", "file": "http://player.vpe.naverncp.com/srt/ncp_overview_script_en_v2.srt", "label": "영어"]
                ]
            ],
            [
                "file": "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8",
                "poster": "https://2ardrvaj2252.edge.naverncp.com/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_01.jpg",
                "description": [
                    "title": "2편 — 두 번째 에피소드",
                    "profile_name": "네이버클라우드",
                    "profile_image": "https://tkmenfxu2702.edge.naverncp.com/profile/202511/cf38c0603c57faacd99cbe6d967c38b3.png",
                    "created_at": "Wed Jul 13 2022 00:00:00 GMT+0900 (한국 표준시)"
                ]
            ]
        ]
    ]

    // MARK: - 입력 State (Configuration 카드)
    @State private var platform: Platform = .pub
    @State private var stage: Stage = .real
    @State private var licenseKey: String = "44fcf7432b280107d7d18148ac24dd99"

    // MARK: - VpePlayer에 실제 전달되는 확정 값 ("적용" 시 갱신)
    @State private var appliedKey: String = "44fcf7432b280107d7d18148ac24dd99"
    @State private var appliedPlatform: String = "pub"
    @State private var appliedStage: String = "real"
    @State private var reloadToken: Int = 0

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            DemoTheme.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // 딕셔너리 옵션을 그대로 VpePlayer(options:)로 전달.
                    VpePlayer(
                        accessKey: appliedKey,
                        platform: appliedPlatform,
                        stage: appliedStage,
                        options: Self.options
                    )
                    .id(reloadToken)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .background(Color.black)

                    VStack(spacing: 16) {
                        appInfoCard
                        configurationCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("기본 플레이어 구성")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func apply() {
        appliedKey = licenseKey
        appliedPlatform = platform.rawValue
        appliedStage = stage.rawValue
        reloadToken += 1
    }

    // MARK: - Cards

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
                        onAction: { apply() }
                    )
                }
            }
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
}

#Preview {
    NavigationStack { BasicPlayerDictView() }
}
