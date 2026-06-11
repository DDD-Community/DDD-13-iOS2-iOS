import SwiftUI

import DesignSystem

struct TopHeroDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                AssetSizeSection("TopHero / large", assetSize: .large)
                AssetSizeSection("TopHero / small", assetSize: .small)

                ButtonVariantSection("TopPage / weak / small", variant: .weak, size: .small)
                ButtonVariantSection("TopPage / solid / medium", variant: .solid, size: .medium)
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

// MARK: - ButtonVariantSection

private struct ButtonVariantSection: View {
    private let title: String
    private let variant: BangawoButton.Variant
    private let size: BangawoButton.Size

    init(
        _ title: String,
        variant: BangawoButton.Variant,
        size: BangawoButton.Size
    ) {
        self.title = title
        self.variant = variant
        self.size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            TopPage(
                asset: Image(systemName: "star.fill"),
                title: "모임 정보를\n확인해 보세요",
                description: "참여 중인 모임의 상세 정보예요",
                buttonTitle: "수정",
                buttonVariant: variant,
                buttonSize: size,
                badgeLabel: "강남역 인근",
                badgeLeadingIcon: Image.Asset.icStar24,
                buttonAction: {}
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
