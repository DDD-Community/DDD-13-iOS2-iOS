import SwiftUI

import DesignSystem

struct MenuDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WithTitleSection()
                WithoutTitleSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Menu")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - WithTitleSection

private struct WithTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("with group title")
            DesignSystem.Menu(
                groupTitle: "그룹 타이틀",
                items: [
                    .init(label: "메뉴 항목 1", icon: Image.Asset.icStar24) {},
                    .init(label: "메뉴 항목 2", icon: Image.Asset.icStar24) {},
                    .init(label: "메뉴 항목 3", icon: Image.Asset.icStar24) {},
                ]
            )
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - WithoutTitleSection

private struct WithoutTitleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("without group title")
            DesignSystem.Menu(
                items: [
                    .init(label: "타이틀 없는 메뉴 1") {},
                    .init(label: "타이틀 없는 메뉴 2") {},
                    .init(label: "타이틀 없는 메뉴 3") {},
                ]
            )
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        MenuDemoView()
    }
}
