import SwiftUI
import VPEPlayer

/// Picture in Picture + 백그라운드 재생 데모.
/// - `allowsPictureInPicture: true` → 앱이 백그라운드로 갈 때 자동 PiP 진입.
/// - `staysActiveInBackground: true` → 백그라운드에서도 오디오 재생 유지.
/// - `enableNowPlayingPlaybackState: true` → 잠금화면/제어센터 Now Playing 연동.
struct PictureInPictureView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": false,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "allowsPictureInPicture": true,
            "staysActiveInBackground": true,
            "enableNowPlayingPlaybackState": true,
            "autoPause": false,
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "PiP / 백그라운드 재생 데모", "profile_name": "VPE"]
                ]
            ]
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VpePlayer(accessKey: accessKey, options: options)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                infoCard
                noteCard
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle("PiP / 백그라운드")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "pip.fill", title: "Picture in Picture") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("PiP", "allowsPictureInPicture: true")
                infoRow("백그라운드", "staysActiveInBackground: true")
                infoRow("Now Playing", "enableNowPlayingPlaybackState: true")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "테스트 방법") {
            Text("재생 중 홈으로 나가거나 다른 앱으로 전환하면 자동으로 PiP(작은 떠 있는 창)로 전환되어 계속 재생됩니다. 잠금화면/제어센터의 Now Playing에서 재생·일시정지도 제어할 수 있습니다. PiP 버튼은 UI에서 제외되어 있으며, 시스템(앱 전환) 트리거로만 동작합니다. (실기기 권장)")
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(key)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
