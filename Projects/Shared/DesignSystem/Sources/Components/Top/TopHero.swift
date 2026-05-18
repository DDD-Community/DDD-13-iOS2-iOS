//
//  TopHero.swift
//  DesignSystem
//

import SwiftUI

public struct TopHero: View {
    // MARK: - Properties

    private let asset: Image?
    private let title: String
    private let description: String
    private let assetSize: AssetSize

    // MARK: - Init

    public init(
        asset: Image? = nil,
        title: String,
        description: String,
        assetSize: AssetSize = .large
    ) {
        self.asset = asset
        self.title = title
        self.description = description
        self.assetSize = assetSize
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let asset {
                TopArea(asset: asset, size: assetSize)
            }
            TitleArea(title: title, description: description)
        }
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing600)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TopArea

private extension TopHero {
    struct TopArea: View {
        let asset: Image
        let size: AssetSize

        var body: some View {
            asset
                .resizable()
                .scaledToFill()
                .frame(width: size.length, height: size.length)
                .clipped()
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(.bottom, size.bottomPadding)
        }
    }
}

// MARK: - TitleArea

private extension TopHero {
    struct TitleArea: View {
        let title: String
        let description: String

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.spacing100) {
                BangawoText(title, textStyle: .headingMedium)
                    .foregroundStyle(Colors.gray900)

                BangawoText(description, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 48) {
            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요"
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요",
                assetSize: .small
            )

            Divider()

            TopHero(
                title: "에셋 없는 경우",
                description: "TopArea가 표시되지 않습니다"
            )
        }
    }
}
