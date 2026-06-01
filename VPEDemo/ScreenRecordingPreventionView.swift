import SwiftUI
import VPEPlayer

/// 화면 녹화 / 스크린 캡처 방지 데모.
/// `option.screenRecordingPrevention = true` 이면 SDK가 `UIScreen.isCaptured`
/// (녹화·미러링·일부 캡처)를 감지해 플레이어를 차단 오버레이(E0014)로 가린다.
struct ScreenRecordingPreventionView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://m4qgahqg2249.edge.naverncp.com/hls/a4oif2oPHP-HlGGWOFm29A__/endpoint/sample/221027_NAVER_Cloud_intro_Long_ver_AVC_,FHD_2Pass_30fps,HD_2Pass_30fps,SD_2Pass_30fps,.mp4.smil/master.m3u8"

    private var optionsJSON: String {
        """
        {
          autostart: true,
          muted: true,
          aspectRatio: "16:9",
          objectFit: "contain",
          screenRecordingPrevention: true,
          playlist: [
            {
              file: "\(streamURL)",
              description: { title: "화면 녹화 방지 데모", profile_name: "VPE" }
            }
          ]
        }
        """
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VpePlayer(accessKey: accessKey, optionsJSON: optionsJSON)
                    .aspectRatio(16.0 / 9.0, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                infoCard
                noteCard
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle("화면 녹화 방지")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var infoCard: some View {
        DemoCard(icon: "eye.slash.fill", title: "ScreenRecordingPrevention") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("옵션", "screenRecordingPrevention: true")
                infoRow("감지", "UIScreen.isCaptured (녹화·미러링)")
                infoRow("동작", "감지 시 화면 차단 오버레이(E0014)")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "테스트 방법") {
            Text("제어센터에서 화면 녹화를 시작하거나 AirPlay/케이블로 화면 미러링을 켜면, 플레이어가 즉시 검은 차단 화면으로 가려집니다. 녹화를 끄면 다시 재생 화면이 보입니다. (시뮬레이터에서는 화면 녹화 API가 동작하지 않을 수 있어 실기기 권장)")
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
                .frame(width: 56, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }
}
