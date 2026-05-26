import SwiftUI

import DesignSystem

struct ToastDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ExamplesSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Toast")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ExamplesSection

private struct ExamplesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("examples")
            VStack(alignment: .center, spacing: 0) {
                Toast("토스트 메시지입니다")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                RowDivider()
                Toast("짧은 메시지")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                RowDivider()
                Toast("조금 더 긴 토스트 메시지가 표시됩니다")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        ToastDemoView()
    }
}
