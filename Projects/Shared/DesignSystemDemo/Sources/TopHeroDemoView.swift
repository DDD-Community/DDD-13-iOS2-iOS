import SwiftUI

import DesignSystem

struct TopHeroDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                AssetSizeSection("large", assetSize: .large)
                AssetSizeSection("small", assetSize: .small)
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Top")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AssetSizeSection

private struct AssetSizeSection: View {
    private let title: String
    private let assetSize: TopHero.AssetSize

    init(_ title: String, assetSize: TopHero.AssetSize) {
        self.title = title
        self.assetSize = assetSize
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요",
                assetSize: assetSize
            )
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        TopHeroDemoView()
    }
}
