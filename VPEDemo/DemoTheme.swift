import SwiftUI

/// 데모 앱 다크 테마 팔레트.
enum DemoTheme {
    static let appBackground = Color(red: 0.07, green: 0.07, blue: 0.09)   // 거의 검정
    static let cardBackground = Color(red: 0.11, green: 0.12, blue: 0.15)  // 카드 배경
    static let cardBorder = Color.white.opacity(0.05)
    static let accent = Color(red: 0.15, green: 0.39, blue: 0.92)          // #2563EB 톤
    static let segmentInactive = Color.white.opacity(0.06)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.55)
    static let textTertiary = Color.white.opacity(0.4)
    static let fieldBackground = Color.black.opacity(0.35)
}
