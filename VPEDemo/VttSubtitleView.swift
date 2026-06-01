import SwiftUI
import VPEPlayer

/// VTT 자막 데모.
/// `playlist[].vtt` 배열로 외부 WebVTT 사이드카 자막을 제공한다.
/// 자막 버튼/설정에서 언어를 토글·선택할 수 있고, `default: true`가 초기 선택된다.
/// (자막 표시 스타일은 iOS 접근성 자막 스타일을 따름)
struct VttSubtitleView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    // Sintel(공개 테스트) HLS + 영문/독일어/스페인어 VTT 자막
    private let streamURL = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    private let vttBase = "https://iandevlin.github.io/mdn/video-player-with-captions/subtitles/vtt"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": false,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "VTT 자막 데모", "profile_name": "Sintel"],
                    "vtt": [
                        ["id": "en", "file": "\(vttBase)/sintel-en.vtt", "label": "English", "default": true],
                        ["id": "de", "file": "\(vttBase)/sintel-de.vtt", "label": "Deutsch"],
                        ["id": "es", "file": "\(vttBase)/sintel-es.vtt", "label": "Español"]
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
        .navigationTitle("VTT 자막")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "captions.bubble.fill", title: "VTT 자막") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("형식", "WebVTT (.vtt) 사이드카")
                infoRow("트랙", "English(기본) · Deutsch · Español")
                infoRow("옵션 키", "playlist[].vtt: [{ id, file, label, default }]")
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
