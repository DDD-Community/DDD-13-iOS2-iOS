import SwiftUI

import DesignSystem

struct SectionHeader: View {
    private let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        BangawoText(text.uppercased(), textStyle: .bodyMedium)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }
}

struct RowDivider: View {
    var body: some View {
        Divider().padding(.leading, 16)
    }
}

struct DemoRow<Content: View>: View {
    private let label: String
    private let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        HStack {
            BangawoText(label, textStyle: .labelSmall)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

extension View {
    func card() -> some View {
        self
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
