import SwiftUI
import VPEPlayer

/// "원격 API 데모" — 옵션 JSON을 원격 API에서 받아 `VpePlayer`로 재생하는 예시.
/// `https://vpe.sgrsoft.com/api/playUrl?v=1` 응답(옵션 JSON)을 그대로 SDK에 전달.
struct RemoteApiPlayerView: View {

    private static let apiURL = URL(string: "https://vpe.sgrsoft.com/api/playUrl?v=1")!
    private static let accessKey = "44fcf7432b280107d7d18148ac24dd99"

    @State private var optionsJSON: String?
    @State private var loadError: String?

    var body: some View {
        ZStack(alignment: .top) {
            DemoTheme.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    playerArea

                    VStack(spacing: 16) {
                        apiInfoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("원격 API 데모")
        .navigationBarTitleDisplayMode(.inline)
        .task { await fetchOptions() }
    }

    // MARK: - 플레이어 / 로딩 / 에러

    @ViewBuilder
    private var playerArea: some View {
        if let json = optionsJSON {
            // 원격에서 받은 옵션 JSON을 그대로 VpePlayer에 전달 (web <VpePlayer> 방식).
            VpePlayer(
                accessKey: Self.accessKey,
                platform: "pub",
                stage: "real",
                optionsJSON: json
            )
            .frame(maxWidth: .infinity)   // 종횡비는 SDK가 option.aspectRatio로 결정
            .clipped()
            .background(Color.black)
        } else {
            // 로딩/에러 placeholder (16:9 박스)
            ZStack {
                Color.black
                if let err = loadError {
                    VStack(spacing: 8) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.8))
                        Text("옵션을 불러오지 못했습니다")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(err)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                        Button("다시 시도") { retry() }
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DemoTheme.accent)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                } else {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - API 정보 카드

    private var apiInfoCard: some View {
        DemoCard(icon: "network", title: "Remote API") {
            VStack(alignment: .leading, spacing: 10) {
                infoRow("endpoint", Self.apiURL.absoluteString)
                infoRow("status", optionsJSON != nil ? "loaded" : (loadError != nil ? "error" : "loading…"))
                if let json = optionsJSON {
                    Text("응답 JSON")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DemoTheme.textTertiary)
                        .padding(.top, 4)
                    Text(json)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(DemoTheme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(DemoTheme.fieldBackground)
                        )
                        .textSelection(.enabled)
                }
            }
        }
    }

    private func infoRow(_ k: String, _ v: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(k)
                .frame(width: 70, alignment: .leading)
                .foregroundStyle(DemoTheme.textTertiary)
            Text(v)
                .foregroundStyle(DemoTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.system(size: 12, design: .monospaced))
    }

    // MARK: - Fetch

    private func retry() {
        loadError = nil
        optionsJSON = nil
        Task { await fetchOptions() }
    }

    private func fetchOptions() async {
        guard optionsJSON == nil else { return }
        do {
            var req = URLRequest(url: Self.apiURL)
            req.timeoutInterval = 15
            req.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                loadError = "HTTP \((resp as? HTTPURLResponse)?.statusCode ?? -1)"
                return
            }
            optionsJSON = String(decoding: data, as: UTF8.self)
        } catch {
            loadError = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack { RemoteApiPlayerView() }
}
