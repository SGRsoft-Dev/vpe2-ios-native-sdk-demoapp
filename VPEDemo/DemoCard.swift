import SwiftUI

/// 데모 화면에서 사용하는 카드 컨테이너 (다크 + 둥근 모서리 + 헤더 아이콘).
struct DemoCard<Content: View>: View {
    let icon: String
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DemoTheme.textPrimary)
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DemoTheme.textPrimary)
                Spacer()
            }
            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DemoTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(DemoTheme.cardBorder, lineWidth: 1)
                )
        )
    }
}

/// 라벨 + 컨트롤 묶음. ("PLATFORM" 같은 작은 회색 라벨)
struct DemoLabeledField<Content: View>: View {
    let label: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(DemoTheme.textTertiary)
            content()
        }
    }
}

/// 2-탭 세그먼티드 토글 (pub/gov, real/beta 처럼).
struct DemoSegmented<T: Hashable>: View {
    let options: [(T, String)]
    @Binding var selection: T

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.0) { value, label in
                Button {
                    withAnimation(.easeOut(duration: 0.15)) { selection = value }
                } label: {
                    Text(label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DemoTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(selection == value ? DemoTheme.accent : DemoTheme.segmentInactive)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// 다크 텍스트 입력 박스 + 옆에 액션 버튼.
struct DemoFieldWithAction: View {
    @Binding var text: String
    let actionLabel: String
    let onAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("", text: $text)
                .textFieldStyle(.plain)
                .font(.system(size: 14, design: .monospaced))
                .foregroundStyle(DemoTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(DemoTheme.fieldBackground)
                )

            Button(action: onAction) {
                Text(actionLabel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(DemoTheme.textPrimary)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(DemoTheme.accent)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

/// 액션 버튼 (재생/일시정지 등). 풀폭, 아이콘 + 라벨.
struct DemoActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(DemoTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DemoTheme.accent)
            )
        }
        .buttonStyle(.plain)
    }
}
