import SwiftUI

import DesignSystem

struct SnackBarDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ExamplesSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("SnackBar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ExamplesSection

private struct ExamplesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("examples")
            VStack(spacing: 0) {
                SnackBar("안내 메시지가 여기에 표시됩니다", buttonTitle: "확인") {}
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                RowDivider()
                SnackBar("짧은 메시지", buttonTitle: "닫기") {}
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                RowDivider()
                SnackBar("긴 안내 메시지가 여기에 길게 표시될 수 있습니다", buttonTitle: "확인") {}
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
        SnackBarDemoView()
    }
}
