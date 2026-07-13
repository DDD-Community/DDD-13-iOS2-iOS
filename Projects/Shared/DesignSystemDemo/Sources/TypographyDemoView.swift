import SwiftUI

import DesignSystem

struct TextDemoView: View {
    @State private var isMultiline = false
    private let styles: [(String, CustomSizeFont)] = [
        ("display/large", .displayLarge),
        ("display/medium", .displayMedium),
        ("display/small", .displaySmall),
        ("heading/large", .headingLarge),
        ("heading/medium", .headingMedium),
        ("heading/small", .headingSmall),
        ("title/large", .titleLarge),
        ("title/medium", .titleMedium),
        ("title/medium/em", .titleMediumEmphasized),
        ("title/small", .titleSmall),
        ("body/large", .bodyLarge),
        ("body/large/em", .bodyLargeEmphasized),
        ("body/medium", .bodyMedium),
        ("body/medium/em", .bodyMediumEmphasized),
        ("body/small", .bodySmall),
        ("body/xsmall", .bodyXSmall),
        ("label/large", .labelLarge),
        ("label/medium", .labelMedium),
        ("label/small", .labelSmall),
        ("label/small/em", .labelSmallEmphasized),
        ("label/xsmall", .labelXSmall),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                stylesSection(multiline: isMultiline)
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Text")
        .toolbar {
            Toggle("Multiline", isOn: $isMultiline)
                .toggleStyle(.switch)
        }
    }

    private func stylesSection(multiline: Bool) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(styles.enumerated()), id: \.offset) { index, item in
                let (label, style) = item
                HStack(alignment: .top, spacing: 12) {
                    BangawoText(label, textStyle: .bodyXSmall)
                        .foregroundStyle(.secondary)
                        .frame(width: 110, alignment: .leading)
                        .padding(.top, 2)
                    BangawoText(
                        multiline ? "가나다라마바사\n아자차카타파하" : "가나다라마바사",
                        textStyle: style
                    )
                    .background(Color.blue.opacity(0.1))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                if index < styles.count - 1 {
                    RowDivider()
                }
            }
        }
        .card()
    }
}

#Preview {
    NavigationStack {
        TextDemoView()
    }
}
