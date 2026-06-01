import SwiftUI
import VPEPlayer

/// SRT 자막 데모.
/// `playlist[].srt` 배열로 외부 SRT 사이드카 자막을 제공한다.
/// 자막 버튼/설정에서 언어를 토글·선택할 수 있고, `default: true`가 초기 선택된다.
/// (자막 표시 스타일은 iOS 접근성 자막 스타일을 따름)
struct SrtSubtitleView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": false,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "SRT 자막 데모", "profile_name": "네이버클라우드"],
                    "srt": [
                        ["id": "ko", "file": "https://player.vpe.naverncp.com/srt/ncp_overview_script_kr_v2.srt", "label": "한국어", "default": true],
                        ["id": "en", "file": "https://player.vpe.naverncp.com/srt/ncp_overview_script_en_v2.srt", "label": "English"]
                    ]
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
        .navigationTitle("SRT 자막")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "captions.bubble.fill", title: "SRT 자막") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("형식", "SRT (.srt) 사이드카")
                infoRow("트랙", "한국어(기본) · English")
                infoRow("옵션 키", "playlist[].srt: [{ id, file, label, default }]")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "동작") {
            Text("컨트롤바의 자막 버튼으로 자막을 켜고, 설정에서 언어를 전환할 수 있습니다. default:true 트랙이 초기 선택됩니다. 자막 텍스트 스타일은 iOS 접근성(설정 > 손쉬운 사용 > 자막 및 캡션) 설정을 따릅니다.")
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
                .frame(width: 64, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
