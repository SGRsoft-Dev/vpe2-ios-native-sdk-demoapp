import SwiftUI
import VPEPlayer

/// HLS 매니페스트 내장(in-manifest) 자막 데모.
/// 스트림의 `EXT-X-MEDIA TYPE=SUBTITLES` 트랙을 AVFoundation `AVMediaSelectionGroup`으로
/// 노출한다. 별도 사이드카(vtt/srt) 없이, 매니페스트에 포함된 자막을 자막/설정 버튼에서
/// 선택할 수 있다. 내장 자막은 AVPlayer가 비디오 레이어에 직접 렌더하며 기본은 OFF.
struct EmbeddedSubtitleView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://playertest.longtailvideo.com/adaptive/elephants_dream_v4/index.m3u8"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": false,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "HLS 내장 자막 데모", "profile_name": "VPE"]
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
        .navigationTitle("내장 자막")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "captions.bubble.fill", title: "HLS 내장 자막") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("형식", "HLS 내장 자막 (EXT-X-MEDIA, AVMediaSelectionGroup)")
                infoRow("트랙", "Chinese · French (매니페스트 내장)")
                infoRow("옵션 키", "별도 자막 옵션 불필요 — 매니페스트에서 자동 인식")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "동작") {
            Text("매니페스트에 포함된 자막 트랙은 AVPlayer가 비디오 위에 직접 렌더하며, 컨트롤바의 자막 버튼/설정에서 선택할 수 있습니다. SDK 정책에 따라 기본은 OFF이며, 외부 사이드카 자막과 동일한 자막 목록에 함께 나타납니다. (시뮬레이터에서는 내장 자막 렌더가 제한될 수 있어 실기기 확인을 권장합니다.)")
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
