import SwiftUI
import DesignSystem

struct NavigationDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                MainSection()
                PageSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Navigation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - MainSection

private struct MainSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("NavigationMain")
            VStack(spacing: 0) {
                NavItem("타이틀") {
                    NavigationMain(background: .clear, title: "반가워")
                }
                RowDivider()
                NavItem("타이틀 + 아이콘") {
                    NavigationMain(
                        background: .clear,
                        title: "반가워",
                        trailingIcons: [
                            NavigationIconItem(icon: .user24) {},
                            NavigationIconItem(icon: .verticalMenu24) {}
                        ]
                    )
                }
                RowDivider()
                NavItem("아이콘만") {
                    NavigationMain(
                        background: .clear,
                        trailingIcons: [
                            NavigationIconItem(icon: .ball24) {}
                        ]
                    )
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - PageSection

private struct PageSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("NavigationPage")
            VStack(spacing: 0) {
                NavItem("뒤로가기 + 타이틀") {
                    NavigationPage(background: .clear, leadingAction: {}, title: "설정")
                }
                RowDivider()
                NavItem("뒤로가기 + 타이틀 + 아이콘") {
                    NavigationPage(
                        background: .clear,
                        leadingAction: {},
                        title: "상세 페이지",
                        trailingIcons: [
                            NavigationIconItem(icon: .verticalMenu24) {}
                        ]
                    )
                }
                RowDivider()
                NavItem("타이틀만") {
                    NavigationPage(background: .clear, title: "알림")
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - NavItem

private struct NavItem<Content: View>: View {
    private let label: String
    private let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BangawoText(label, textStyle: .labelSmall)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.top, 10)
            content
        }
    }
}

#Preview {
    NavigationStack {
        NavigationDemoView()
    }
}
