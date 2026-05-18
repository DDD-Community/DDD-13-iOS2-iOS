import SwiftUI
import DesignSystem

struct CheckboxDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                CheckboxVariantSection("circle", variant: .circle)
                CheckboxVariantSection("ghost", variant: .ghost)
                CheckboxRowSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Checkbox")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - CheckboxVariantSection

private struct CheckboxVariantSection: View {
    private let title: String
    private let variant: Checkbox.Variant

    init(_ title: String, variant: Checkbox.Variant) {
        self.title = title
        self.variant = variant
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            VStack(spacing: 0) {
                DemoRow("small / enabled") { Checkbox(variant: variant, state: .enabled, size: .small) }
                RowDivider()
                DemoRow("small / disabled") { Checkbox(variant: variant, state: .disabled, size: .small) }
                RowDivider()
                DemoRow("medium / enabled") { Checkbox(variant: variant, state: .enabled, size: .medium) }
                RowDivider()
                DemoRow("medium / disabled") { Checkbox(variant: variant, state: .disabled, size: .medium) }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - CheckboxRowSection

private struct CheckboxRowSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("CheckboxRow")
            VStack(spacing: 0) {
                CheckboxRow("제목만 있는 항목")
                    .arrow(.right)
                RowDivider()
                CheckboxRow("설명이 있는 항목")
                    .description("부가 설명이 표시됩니다")
                    .arrow(.right)
                RowDivider()
                CheckboxRow("ghost variant", checkboxVariant: .ghost)
                    .description("ghost 스타일 체크박스")
                    .arrow(.down)
                RowDivider()
                CheckboxRow("disabled", checkboxState: .disabled)
                    .description("비활성화된 항목입니다")
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        CheckboxDemoView()
    }
}
