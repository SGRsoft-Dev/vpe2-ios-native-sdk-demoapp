import SwiftUI
import VPEPlayer

/// 메서드(명령형 API) 제어 데모.
/// `VpePlayer` 컴포넌트 대신 `VPEPlayerController`를 직접 보유하고,
/// `VPEPlayerView(controller:)`로 화면에 띄운 뒤 외부 커스텀 버튼에서
/// `play()/pause()/seek()/setRate()/enterFullscreen()` 등 SDK 메서드로 제어한다.
/// (web `playerRef.current.play()` 핸들 방식에 대응)
///
/// 내장 컨트롤바는 끄고(`showsBuiltinControls: false`) 아래 커스텀 패널로만 제어.
struct ImperativeControlView: View {
    @StateObject private var player = VPEPlayerController(
        options: [
            "autostart": false,
            "muted": false,
            "controls": false,          // 외부 버튼으로만 제어
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "playlist": [
                [
                    "file": "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8",
                    "description": ["title": "명령형 제어 데모", "profile_name": "VPE"]
                ]
            ]
        ],
        accessKey: "44fcf7432b280107d7d18148ac24dd99",
        platform: "pub",
        stage: "real"
    )

    private let rates: [Float] = [0.5, 1.0, 1.5, 2.0]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 내장 컨트롤 없이 컨트롤러를 직접 들고 표시
                VPEPlayerView(controller: player, showsBuiltinControls: false)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                stateCard
                transportCard
                seekCard
                rateVolumeCard
                infoCard
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle("메서드 제어")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 상태 (read-only @Published 관찰)

    private var stateCard: some View {
        DemoCard(icon: "waveform", title: "상태 (실시간)") {
            VStack(alignment: .leading, spacing: 8) {
                stateRow("isPlaying", player.isPlaying ? "true" : "false")
                stateRow("currentTime", String(format: "%.1f s", player.currentTime))
                stateRow("duration", player.isLive ? "LIVE" : String(format: "%.1f s", player.duration))
                stateRow("rate", String(format: "%.2gx", player.playbackRate))
                stateRow("isFullscreen", player.isFullscreen ? "true" : "false")
            }
        }
    }

    // MARK: - 트랜스포트

    private var transportCard: some View {
        DemoCard(icon: "play.circle", title: "재생 제어") {
            HStack(spacing: 10) {
                ctrlButton("play.fill", "play") { player.play() }
                ctrlButton("pause.fill", "pause") { player.pause() }
                ctrlButton("playpause.fill", "toggle") { player.toggle() }
                ctrlButton("arrow.counterclockwise", "restart") { player.restart() }
            }
        }
    }

    // MARK: - 시킹

    private var seekCard: some View {
        DemoCard(icon: "timeline.selection", title: "탐색 (seek)") {
            HStack(spacing: 10) {
                ctrlButton("gobackward.10", "-10s") {
                    player.seek(to: max(0, player.currentTime - 10))
                }
                ctrlButton("goforward.10", "+10s") {
                    player.seek(to: player.currentTime + 10)
                }
                ctrlButton("backward.end.fill", "처음") { player.seek(to: 0) }
                ctrlButton(player.isFullscreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right",
                           "전체화면") { player.toggleFullscreen() }
            }
        }
    }

    // MARK: - 배속 / 볼륨

    private var rateVolumeCard: some View {
        DemoCard(icon: "speedometer", title: "배속 / 음소거") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    ForEach(rates, id: \.self) { r in
                        Button { player.setRate(r) } label: {
                            Text(String(format: "%.2gx", r))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(player.playbackRate == r ? .white : DemoTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .fill(player.playbackRate == r ? DemoTheme.accent : DemoTheme.fieldBackground)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack(spacing: 10) {
                    ctrlButton("speaker.fill", "음소거") { player.setMuted(true) }
                    ctrlButton("speaker.wave.2.fill", "해제") { player.setMuted(false) }
                }
            }
        }
    }

    private var infoCard: some View {
        DemoCard(icon: "info.circle.fill", title: "구현 방식") {
            Text("VpePlayer 컴포넌트 대신 VPEPlayerController를 @StateObject로 직접 보유하고, VPEPlayerView(controller:showsBuiltinControls:false)로 표시합니다. 위 버튼들은 controller.play()/pause()/seek()/setRate()/setMuted()/toggleFullscreen() 등 SDK 메서드를 직접 호출하고, 상태 카드는 controller의 @Published 값을 SwiftUI가 자동 관찰합니다. (web playerRef.current.* 핸들 방식과 동일)")
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Helpers

    private func ctrlButton(_ icon: String, _ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 18, weight: .semibold))
                Text(label).font(.system(size: 11))
            }
            .foregroundStyle(DemoTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(DemoTheme.fieldBackground)
            )
        }
        .buttonStyle(.plain)
    }

    private func stateRow(_ key: String, _ value: String) -> some View {
        HStack(spacing: 8) {
            Text(key)
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(DemoTheme.accent)
            Spacer(minLength: 0)
        }
    }
}
