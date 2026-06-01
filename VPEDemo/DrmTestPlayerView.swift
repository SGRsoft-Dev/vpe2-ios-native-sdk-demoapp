import SwiftUI
import VPEPlayer

/// DRM 재생 데모 (NCP Multi-DRM / PallyCon 공용).
/// 원격 API에서 DRM 옵션 JSON을 받아 그대로 `VpePlayer` 에 주입한다.
/// iOS(AVFoundation)는 키 시스템 중 **FairPlay(HLS)** 경로만 사용한다.
///
/// ⚠️ FairPlay Streaming은 보안 칩 의존으로 **실기기에서만** 복호화된다(시뮬레이터 재생 불가).
struct DrmTestPlayerView: View {
    let endpoint: String
    let navTitle: String
    let provider: String     // "NCP" | "PallyCon"
    let authNote: String
    let extraNote: String?
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"

    init(endpoint: String = "https://vpe.sgrsoft.com/api/drmTest",
         navTitle: String = "원클릭 멀티 DRM",
         provider: String = "NCP",
         authNote: String = "NCP API Gateway 인증 헤더(x-ncp-iam-access-key, x-ncp-apigw-signature-v2, x-drm-token)를 cert/license 요청에 그대로 전달합니다.",
         extraNote: String? = nil) {
        self.endpoint = endpoint
        self.navTitle = navTitle
        self.provider = provider
        self.authNote = authNote
        self.extraNote = extraNote
    }

    @State private var state: LoadState = .loading
    @State private var systems: [String] = []
    @State private var licenseEndpoint: String = ""
    @State private var fairplaySrc: String = ""

    private enum LoadState: Equatable {
        case loading
        case loaded(String)
        case failed(String)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                switch state {
                case .loading:
                    loadingCard
                case .loaded(let json):
                    VpePlayer(accessKey: accessKey, optionsJSON: json)
                        .aspectRatio(16.0 / 9.0, contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    drmInfoCard(json: json)
                    if let extra = extraNote { mockNoteCard(extra) }
                    simulatorNoteCard
                case .failed(let message):
                    errorCard(message)
                }
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle(navTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private var loadingCard: some View {
        DemoCard(icon: "lock.shield", title: "\(provider) DRM") {
            HStack(spacing: 10) {
                ProgressView()
                Text("DRM 옵션 수신 중…")
                    .font(.system(size: 13))
                    .foregroundStyle(DemoTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func drmInfoCard(json: String) -> some View {
        DemoCard(icon: "lock.shield.fill", title: "DRM 구성 · \(provider)") {
            VStack(alignment: .leading, spacing: 8) {
                infoRow("Key 시스템", systems.isEmpty ? "-" : systems.joined(separator: ", "))
                infoRow("재생 경로", "FairPlay (HLS) · iOS")
                infoRow("License", licenseEndpoint.isEmpty ? "-" : licenseEndpoint)
                if !fairplaySrc.isEmpty {
                    infoRow("Stream", fairplaySrc)
                }
                Divider().overlay(DemoTheme.cardBorder)
                Text("인증")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DemoTheme.textSecondary)
                Text(authNote)
                    .font(.system(size: 12))
                    .foregroundStyle(DemoTheme.textTertiary)
            }
        }
    }

    private func mockNoteCard(_ text: String) -> some View {
        DemoCard(icon: "info.circle.fill", title: "참고") {
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var simulatorNoteCard: some View {
        DemoCard(icon: "exclamationmark.triangle.fill", title: "실기기 필요") {
            Text("FairPlay Streaming은 보안 칩에 의존하므로 시뮬레이터에서는 복호화/재생이 되지 않습니다. 실제 iPhone/iPad에서 확인하세요.")
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func errorCard(_ message: String) -> some View {
        DemoCard(icon: "exclamationmark.triangle", title: "오류") {
            VStack(alignment: .leading, spacing: 12) {
                Text(message)
                    .font(.system(size: 13))
                    .foregroundStyle(DemoTheme.textSecondary)
                Button {
                    Task { await load() }
                } label: {
                    Text("다시 시도")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(DemoTheme.accent, in: Capsule())
                }
            }
        }
    }

    private func infoRow(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(key)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textTertiary)
                .textSelection(.enabled)
            Spacer(minLength: 0)
        }
    }

    private func load() async {
        state = .loading
        guard let url = URL(string: endpoint) else {
            state = .failed("잘못된 엔드포인트 URL")
            return
        }
        do {
            var req = URLRequest(url: url)
            req.timeoutInterval = 15
            req.cachePolicy = .reloadIgnoringLocalCacheData   // 서명/토큰은 매 요청 갱신 → 항상 최신 수신
            let (data, response) = try await URLSession.shared.data(for: req)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                state = .failed("서버 응답 오류")
                return
            }
            guard let json = String(data: data, encoding: .utf8) else {
                state = .failed("JSON 디코드 실패")
                return
            }
            parseSummary(data)
            state = .loaded(json)
        } catch {
            state = .failed("네트워크 오류: \(error.localizedDescription)")
        }
    }

    /// 표시용 요약 파싱(재생 옵션은 SDK가 직접 파싱).
    private func parseSummary(_ data: Data) {
        guard
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let playlist = root["playlist"] as? [[String: Any]],
            let first = playlist.first,
            let drm = first["drm"] as? [String: Any]
        else { return }

        var found: [String] = []
        if drm["com.widevine.alpha"] != nil { found.append("Widevine") }
        if drm["com.microsoft.playready"] != nil { found.append("PlayReady") }
        if let fps = drm["com.apple.fps"] as? [String: Any] {
            found.append("FairPlay")
            licenseEndpoint = fps["licenseUri"] as? String ?? ""
            fairplaySrc = fps["src"] as? String ?? ""
        }
        systems = found
    }
}
