import SwiftUI
import VPEPlayer

/// 라이브 스트림 데모.
/// Mux 테스트 라이브 HLS(`live=1`)를 재생한다.
///
/// 라이브는 duration이 무한이라 SDK가 자동으로 `isLive`를 판정하지만,
/// 여기서는 `option.live = true` 로 명시해 즉시 라이브 UI(LIVE 라벨, SeekBar 숨김)를 적용한다.
struct LiveStreamPlayerView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://stream.mux.com/v69RSHhFelSm4701snP22dYz2jICy4E4FUyk02rW4gxRM.m3u8"

    private var options: [String: Any] {
        [
            "live": true,
            "autostart": true,
            "muted": true,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "Mux 라이브 테스트 스트림", "profile_name": "Mux"]
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
        .navigationTitle("라이브 스트림")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "dot.radiowaves.left.and.right", title: "Live Stream") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("프로토콜", "HLS (.m3u8) · AVPlayer")
                infoRow("소스", "Mux 테스트 라이브")
                infoRow("URL", streamURL)
                Divider().overlay(DemoTheme.cardBorder)
                Text("라이브 모드")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DemoTheme.textSecondary)
                Text("option.live=true → 컨트롤바가 라이브 레이아웃으로 전환됩니다. 시간 표시는 'LIVE'(빨간 점), SeekBar/탐색은 숨김 처리됩니다.")
                    .font(.system(size: 12))
                    .foregroundStyle(DemoTheme.textTertiary)
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "참고") {
            Text("이 Mux 샘플 URL은 만료 가능한 서명(live=1, expires)이 포함되어 있어 시간이 지나면 재생되지 않을 수 있습니다. 라이브 자동 판정은 duration이 무한일 때도 동작합니다.")
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
