import SwiftUI
import VPEPlayer

/// Now Playing 데모.
/// `enableNowPlayingPlaybackState: true` → 잠금화면 / 제어센터 미니플레이어에
/// 현재 영상 메타데이터(제목·아티스트)와 재생 상태/시간을 노출하고,
/// 원격 명령(재생·일시정지·±10초·트랙 이동)을 받는다.
///
/// 백그라운드 오디오 유지를 위해 `staysActiveInBackground: true` 도 함께 사용.
struct NowPlayingView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": false,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "staysActiveInBackground": true,
            "enableNowPlayingPlaybackState": true,
            "allowsPictureInPicture": false,
            "autoPause": false,
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "Now Playing 데모", "profile_name": "VPE Player"]
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
        .navigationTitle("Now Playing")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "play.square.stack.fill", title: "Now Playing") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("옵션", "enableNowPlayingPlaybackState: true")
                infoRow("메타", "제목 / 아티스트 / 재생시간")
                infoRow("원격 명령", "재생 · 일시정지 · ±10초 · 트랙 이동")
                infoRow("연동", "잠금화면 · 제어센터 미니플레이어")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "테스트 방법") {
            Text("재생 중 기기를 잠그거나 제어센터를 열면, 미디어 위젯에 영상 제목·아티스트와 현재 재생 위치가 표시됩니다. 위젯의 재생/일시정지, 15초 건너뛰기, 트랙 이동 버튼으로 플레이어를 원격 제어할 수 있습니다. (시뮬레이터에서는 제한적이며 실기기 권장)")
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
                .frame(width: 72, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
