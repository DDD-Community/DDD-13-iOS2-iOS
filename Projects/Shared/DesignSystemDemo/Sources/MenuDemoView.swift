import SwiftUI
import DesignSystem

struct MenuDemoView: View {
    @State private var selectedIndex1: Int? = 0
    @State private var selectedIndex2: Int? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                WithTitleSection(selectedIndex: $selectedIndex1)
                WithoutTitleSection(selectedIndex: $selectedIndex2)
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
    @Binding private var selectedIndex: Int?

    init(selectedIndex: Binding<Int?>) {
        self._selectedIndex = selectedIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("with group title")
            DesignSystem.Menu(
                groupTitle: "그룹 타이틀",
                selectedIndex: $selectedIndex,
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
    @Binding private var selectedIndex: Int?

    init(selectedIndex: Binding<Int?>) {
        self._selectedIndex = selectedIndex
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("without group title")
            DesignSystem.Menu(
                selectedIndex: $selectedIndex,
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
