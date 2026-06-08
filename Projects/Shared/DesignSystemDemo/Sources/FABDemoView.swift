import SwiftUI

import DesignSystem

struct FABDemoView: View {
    @State private var isPressed = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                StateSection(isPressed: $isPressed)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, 16)

            FAB(
                isPressed: $isPressed,
                menuItems: [
                    .init(label: "모임 만들기", icon: .Asset.icPlus24) {},
                    .init(label: "모임 참여하기", icon: .Asset.icUsersPlus24) {},
                ]
            )
            .padding(.trailing, 20)
            .padding(.bottom, 40)
        }
        .navigationTitle("FAB")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - StateSection

private struct StateSection: View {
    @Binding private var isPressed: Bool

    init(isPressed: Binding<Bool>) {
        self._isPressed = isPressed
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("State")

            VStack(alignment: .leading, spacing: 12) {
                BangawoText("현재 상태: \(isPressed ? "pressed" : "enabled")", textStyle: .bodyMedium)
                    .foregroundStyle(.secondary)

                BangawoText("우측 하단의 FAB를 탭하면 상태가 전환됩니다.", textStyle: .bodySmall)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FABDemoView()
    }
}
