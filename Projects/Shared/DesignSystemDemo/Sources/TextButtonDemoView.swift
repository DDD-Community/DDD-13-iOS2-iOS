import SwiftUI

import DesignSystem

struct TextButtonDemoView: View {
    @State private var isDisabled = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ControlSection(isDisabled: $isDisabled)
                TypeSection("textOnly", type: .textOnly, isDisabled: isDisabled)
                TypeSection("textWithArrow", type: .textWithArrow, isDisabled: isDisabled)
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("TextButton")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ControlSection

private struct ControlSection: View {
    @Binding private var isDisabled: Bool

    init(isDisabled: Binding<Bool>) {
        self._isDisabled = isDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Controls")
            Toggle("Disabled", isOn: $isDisabled)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - TypeSection

private struct TypeSection: View {
    private let title: String
    private let type: TextButton.ButtonType
    private let isDisabled: Bool

    init(_ title: String, type: TextButton.ButtonType, isDisabled: Bool) {
        self.title = title
        self.type = type
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            VStack(spacing: 0) {
                DemoRow("large") { TextButton("Label", type: type, size: .large, isDisabled: isDisabled) {} }
                RowDivider()
                DemoRow("medium") { TextButton("Label", type: type, size: .medium, isDisabled: isDisabled) {} }
                RowDivider()
                DemoRow("small") { TextButton("Label", type: type, size: .small, isDisabled: isDisabled) {} }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        TextButtonDemoView()
    }
}
