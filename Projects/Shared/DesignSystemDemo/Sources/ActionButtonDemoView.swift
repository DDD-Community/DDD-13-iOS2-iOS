import SwiftUI

import DesignSystem

struct ActionButtonDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                LayoutSection(
                    "single",
                    layout: .single(title: "확인", action: {})
                )
                LayoutSection(
                    "dual / vertical",
                    layout: .dual(
                        primaryTitle: "확인", primaryAction: {},
                        secondaryTitle: "취소", secondaryAction: {},
                        arrangement: .vertical
                    )
                )
                LayoutSection(
                    "dual / horizontal",
                    layout: .dual(
                        primaryTitle: "확인", primaryAction: {},
                        secondaryTitle: "취소", secondaryAction: {},
                        arrangement: .horizontal
                    )
                )
                UpperContentSection()
                LowerContentSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("ActionButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - LayoutSection

private struct LayoutSection: View {
    private let title: String
    private let layout: ActionButton.ButtonLayout

    init(_ title: String, layout: ActionButton.ButtonLayout) {
        self.title = title
        self.layout = layout
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            ActionButton(buttonLayout: layout)
                .padding(.vertical, 16)
                .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - UpperContentSection

private struct UpperContentSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("upperContent")
            VStack(spacing: 0) {
                ActionButton(
                    buttonLayout: .single(title: "확인", action: {}),
                    upperContent: .description("안내 문구가 여기에 표시됩니다")
                )
                .padding(.vertical, 16)

                RowDivider()

                ActionButton(
                    buttonLayout: .single(title: "확인", action: {}),
                    upperContent: .toast(message: "토스트 메시지입니다")
                )
                .padding(.vertical, 16)

                RowDivider()

                ActionButton(
                    buttonLayout: .single(title: "확인", action: {}),
                    upperContent: .snackBar(message: "안내 메시지입니다", buttonTitle: "닫기", action: {})
                )
                .padding(.vertical, 16)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - LowerContentSection

private struct LowerContentSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("lowerContent")
            ActionButton(
                buttonLayout: .single(title: "확인", action: {}),
                lowerContent: .init("더 알아보기", type: .textWithArrow, action: {})
            )
            .padding(.vertical, 16)
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        ActionButtonDemoView()
    }
}
