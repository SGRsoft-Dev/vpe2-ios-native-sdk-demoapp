import SwiftUI
import VPEPlayer

/// 워터마크 데모.
/// web SDK와 동일한 옵션으로 워터마크를 표시한다.
/// - `visibleWatermark: true` + `watermarkText`
/// - `watermarkConfig.randPosition`: true면 `randPositionInterVal`(ms)마다 무작위 위치 이동.
///   false면 `x`/`y`(0~100 %)로 고정.
/// - `watermarkConfig.opacity`: 0~1 (web 기본 0.5)
///
/// 토글로 randPosition(이동) / 고정 위치 두 모드를 전환해볼 수 있다.
struct WatermarkPlayerView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8"

    @State private var randPosition = true
    @State private var reloadToken = 0

    private var options: [String: Any] {
        var config: [String: Any] = [
            "randPosition": randPosition,
            "randPositionInterVal": 3000,   // web 키(오타 포함) 그대로 — 이동 주기 3초
            "opacity": 0.6
        ]
        if !randPosition {
            // 고정 모드: 우하단 근처(%)
            config["x"] = 70
            config["y"] = 85
        }
        return [
            "autostart": true,
            "muted": true,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "visibleWatermark": true,
            "watermarkText": "NAVER CLOUD PLATFORM",
            "watermarkConfig": config,
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "워터마크 데모", "profile_name": "VPE"]
                ]
            ]
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VpePlayer(accessKey: accessKey, options: options)
                    .id(reloadToken)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                modeCard
                infoCard
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle("워터마크")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var modeCard: some View {
        DemoCard(icon: "drop.fill", title: "워터마크 모드") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $randPosition) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(randPosition ? "랜덤 위치 (이동)" : "고정 위치")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(DemoTheme.textPrimary)
                        Text(randPosition ? "3초마다 무작위 위치로 이동" : "x:70% · y:85% 고정")
                            .font(.system(size: 12))
                            .foregroundStyle(DemoTheme.textTertiary)
                    }
                }
                .tint(DemoTheme.accent)
                .onChange(of: randPosition) { _ in reloadToken += 1 }   // 옵션 변경 → 플레이어 재구성
            }
        }
    }

    private var infoCard: some View {
        DemoCard(icon: "info.circle.fill", title: "Watermark 옵션") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("text", "NAVER CLOUD PLATFORM")
                infoRow("randPosition", randPosition ? "true (3000ms)" : "false")
                infoRow("opacity", "0.6")
                Divider().overlay(DemoTheme.cardBorder)
                Text("randPosition이 true면 randPositionInterVal(ms)마다 텍스트가 잘리지 않는 범위 내에서 무작위로 이동합니다. false면 x/y(0~100%)로 고정됩니다. web vpe-react-sdk와 동일한 옵션·동작입니다.")
                    .font(.system(size: 12))
                    .foregroundStyle(DemoTheme.textTertiary)
            }
        }
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(key)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(width: 96, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
