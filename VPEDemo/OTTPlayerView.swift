import SwiftUI
import VPEPlayer

/// OTT 기능 데모.
/// `Tears of Steel` 테스트 HLS로 인트로/오프닝/엔딩 **스킵 버튼**과
/// **연령등급 / 콘텐츠 경고 고지** 오버레이를 보여준다.
///
/// - intro 0:05~0:20 → "인트로 건너뛰기"
/// - opening 0:30~0:50 → "오프닝 건너뛰기"
/// - ending 9:30~ → "엔딩 건너뛰기"
/// - ageRating "15" + contentWarnings(폭력/공포) → 시작 시 고지 배너
struct OTTPlayerView: View {
    private let accessKey = "44fcf7432b280107d7d18148ac24dd99"
    private let streamURL = "https://test-streams.mux.dev/tos_ismc/main.m3u8"

    private var options: [String: Any] {
        [
            "autostart": true,
            "muted": true,
            "aspectRatio": "16:9",
            "objectFit": "contain",
            "controlActiveTime": 3000,
            "playlist": [
                [
                    "file": streamURL,
                    "description": ["title": "Tears of Steel (OTT 데모)", "profile_name": "Mux"],
                    "ageRating": "15",
                    "contentWarnings": ["violence", "horror"],
                    "intro":   ["start": "00:05", "duration": 15],
                    "opening": ["start": "00:30", "duration": 20],
                    "ending":  ["start": "09:30", "duration": 30]
                ]
            ],
            "layout": layoutDict
        ]
    }

    /// 반응형 컨트롤 레이아웃 (pc/mobile/fullscreen × vod/live).
    private var layoutDict: [String: Any] {
        func blank(_ align: String = "left") -> [String: Any] {
            ["wrapper": "Blank", "items": [String](), "align": align]
        }
        func grp(_ items: [String], cap: Int? = nil) -> [String: Any] {
            var d: [String: Any] = ["items": items, "wrapper": "Group"]
            if let cap { d["cap"] = cap }
            return d
        }
        func plain(_ items: [String]) -> [String: Any] { ["items": items, "wrapper": NSNull()] }
        let bigPlay: [String: Any] = ["items": ["BigPlayBtn"], "align": "center"]
        let seek: [String: Any] = ["wrapper": "Blank", "items": ["SeekBar"], "align": "center"]

        return [
            "pc": [
                "vod": [
                    "order": ["top", "upper", "center", "lower", "bottom"],
                    "top": [["items": ["MetaDesc"]], blank(), ["items": ["ShareBtn"]]],
                    "upper": [blank()],
                    "center": [bigPlay],
                    "lower": [seek],
                    "bottom": [
                        grp(["PlayBtn"]), grp(["NextPrevBtn"]), grp(["VolumeBtn"]), grp(["TimeBtn"]),
                        blank(), grp(["SubtitleBtn", "PipBtn", "SettingBtn", "FullscreenBtn"], cap: 2)
                    ]
                ],
                "live": [
                    "order": ["top", "upper", "center", "lower", "bottom"],
                    "top": [["items": ["MetaDesc"]]],
                    "upper": [blank()],
                    "center": [bigPlay],
                    "lower": [seek],
                    "bottom": [
                        grp(["PlayBtn"]), grp(["NextPrevBtn"]), grp(["TimeBtn"]),
                        blank(), grp(["SubtitleBtn", "PipBtn", "SettingBtn", "FullscreenBtn"], cap: 2)
                    ]
                ]
            ],
            "mobile": [
                "vod": [
                    "order": ["upper", "center", "top", "bottom", "lower"],
                    "top": [plain(["MetaDesc"]), blank(), ["items": [String](), "cap": 2, "wrapper": NSNull()]],
                    "upper": [blank()],
                    "center": [bigPlay],
                    "lower": [plain(["TimeBtn"]), blank(), plain(["SubtitleBtn", "SettingBtn", "FullscreenBtn"])],
                    "bottom": [seek]
                ],
                "live": [
                    "order": ["top", "upper", "center", "lower", "bottom"],
                    "top": [grp(["MuteBtn"]), blank(), grp(["PipBtn", "SettingBtn"], cap: 2)],
                    "upper": [blank()],
                    "center": [bigPlay],
                    "lower": [grp(["TimeBtn"]), blank(), grp(["SubtitleBtn", "FullscreenBtn"])],
                    "bottom": [seek]
                ]
            ],
            "fullscreen": [
                "vod": [
                    "order": ["center", "top", "lower", "bottom"],
                    "top": [plain(["MetaDesc"]), blank(), ["items": [String](), "cap": 2, "wrapper": NSNull()]],
                    "center": [bigPlay],
                    "lower": [seek],
                    "bottom": [
                        grp(["PlayBtn", "PrevBtn", "NextBtn"]), grp(["VolumeBtn"]), grp(["TimeBtn"]),
                        blank(), grp(["SubtitleBtn", "SettingBtn", "FullscreenBtn"], cap: 2)
                    ],
                    "upper": [blank()]
                ],
                "live": [
                    "order": ["top", "center", "lower", "bottom"],
                    "top": [blank()],
                    "center": [bigPlay],
                    "lower": [seek],
                    "bottom": [
                        grp(["PlayBtn", "PrevBtn", "NextBtn"]), grp(["VolumeBtn"]), grp(["TimeBtn"]),
                        blank(), grp(["SubtitleBtn", "SettingBtn", "FullscreenBtn"], cap: 2)
                    ],
                    "upper": [blank()]
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

                featureCard
                noteCard
            }
            .padding(16)
        }
        .background(DemoTheme.appBackground.ignoresSafeArea())
        .navigationTitle("OTT 기능")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var featureCard: some View {
        DemoCard(icon: "tv.fill", title: "OTT 기능") {
            VStack(alignment: .leading, spacing: 10) {
                featureRow("forward.end.fill", "스킵 버튼", "인트로 0:05~0:20 · 오프닝 0:30~0:50 · 엔딩 9:30~")
                featureRow("exclamationmark.shield.fill", "연령등급 고지", "15세 이상 관람가 — 시작 시 좌상단 배너")
                featureRow("exclamationmark.triangle.fill", "콘텐츠 경고", "폭력 · 공포")
            }
        }
    }

    private var noteCard: some View {
        DemoCard(icon: "info.circle.fill", title: "동작 방식") {
            Text("재생 위치가 intro/opening/ending 구간에 들어가면 우하단에 '건너뛰기' 버튼이 나타나고, 탭하면 구간 끝으로 이동합니다. ageRating/contentWarnings는 영상 시작 직후 6초간 안내됩니다. 모든 문구는 SDK i18n(ko/ja/en)에서 자동 번역됩니다.")
                .font(.system(size: 12))
                .foregroundStyle(DemoTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func featureRow(_ icon: String, _ title: String, _ desc: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(DemoTheme.accent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DemoTheme.textPrimary)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundStyle(DemoTheme.textTertiary)
            }
            Spacer(minLength: 0)
        }
    }
}
