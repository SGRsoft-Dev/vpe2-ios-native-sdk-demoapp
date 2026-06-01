import SwiftUI

/// 데모 앱 메인 라우터.
/// NavigationStack root + 메뉴 카드 리스트.
struct ContentView: View {
    var body: some View {
        NavigationStack {
            HomeContent()
                .navigationTitle("VPE iOS Demo")
                .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
        .tint(DemoTheme.accent)
    }
}

private struct HomeContent: View {
    var body: some View {
        ZStack {
            DemoTheme.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    header

                    DemoCard(icon: "list.bullet.rectangle", title: "데모 시나리오") {
                        VStack(spacing: 10) {
                            MenuRow(
                                icon: "play.rectangle.fill",
                                title: "기본 플레이어 구성",
                                subtitle: "NCP HLS · 옵션/이벤트 카드 · 설정 모달",
                                destination: { BasicPlayerView() }
                            )
                            MenuRow(
                                icon: "network",
                                title: "원격 API 데모",
                                subtitle: "playurl API에서 옵션 JSON 수신 → 재생",
                                destination: { RemoteApiPlayerView() }
                            )
                            MenuRow(
                                icon: "lock.shield.fill",
                                title: "원클릭 멀티 DRM",
                                subtitle: "drmTest API · FairPlay(HLS) DRM 재생",
                                destination: { DrmTestPlayerView() }
                            )
                            MenuRow(
                                icon: "lock.rectangle.stack.fill",
                                title: "PallyCon DRM",
                                subtitle: "drmTestPallycon API · FairPlay(HLS) DRM",
                                destination: {
                                    DrmTestPlayerView(
                                        endpoint: "https://vpe.sgrsoft.com/api/drmTestPallycon",
                                        navTitle: "PallyCon DRM",
                                        provider: "PallyCon",
                                        authNote: "PallyCon license 요청에 pallycon-customdata-v2 헤더 + raw SPC(application/octet-stream)를 전달하고, 인증서는 fpsKeyManager.do에서 받습니다.",
                                        extraNote: "이 데모 응답은 PallyCon 옵션 구조 예시(샘플 토큰)입니다. 실제 재생에는 유효한 PallyCon 토큰/콘텐츠가 필요합니다."
                                    )
                                }
                            )
                            DisabledMenuRow(
                                icon: "rectangle.stack.fill",
                                title: "Playlist",
                                subtitle: "(준비 중)"
                            )
                            MenuRow(
                                icon: "dot.radiowaves.left.and.right",
                                title: "라이브 스트림",
                                subtitle: "Mux HLS 라이브 · LIVE 컨트롤 레이아웃",
                                destination: { LiveStreamPlayerView() }
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("VPE PLAYER SDK")
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.8)
                .foregroundStyle(DemoTheme.textTertiary)
            Text("데모 시나리오 선택")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(DemoTheme.textPrimary)
            Text("아래 시나리오를 탭하여 플레이어를 확인하세요.")
                .font(.system(size: 13))
                .foregroundStyle(DemoTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 6)
    }
}

// MARK: - 메뉴 행

private struct MenuRow<Destination: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DemoTheme.accent)
                    .frame(width: 40, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(DemoTheme.accent.opacity(0.18))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DemoTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(DemoTheme.textSecondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DemoTheme.textTertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DemoTheme.fieldBackground)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DisabledMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DemoTheme.textTertiary)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DemoTheme.textSecondary)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(DemoTheme.textTertiary)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(DemoTheme.fieldBackground.opacity(0.5))
        )
        .opacity(0.7)
    }
}

#Preview {
    ContentView()
}
