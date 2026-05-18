//
//  TopHero.swift
//  DesignSystem
//

import SwiftUI

public struct TopHero: View {
    // MARK: - Enums

    public enum LayoutType {
        case leading
        case center
    }

    public enum AssetSize {
        case large  // 104x104, top padding 16
        case small  // 64x64, top padding 24
    }

    public enum BottomContent {
        case single(title: String, action: () -> Void)
        case dual(
            leadingTitle: String,
            leadingAction: () -> Void,
            trailingTitle: String,
            trailingAction: () -> Void
        )
    }

    // MARK: - Properties

    private let asset: Image
    private let title: String
    private let description: String
    private let layoutType: LayoutType
    private let assetSize: AssetSize
    private let bottomContent: BottomContent?

    // MARK: - Init

    public init(
        asset: Image,
        title: String,
        description: String,
        layoutType: LayoutType = .leading,
        assetSize: AssetSize = .large,
        bottomContent: BottomContent? = nil
    ) {
        self.asset = asset
        self.title = title
        self.description = description
        self.layoutType = layoutType
        self.assetSize = assetSize
        self.bottomContent = bottomContent
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: contentAlignment, spacing: 0) {
            asset
                .resizable()
                .scaledToFill()
                .frame(width: assetSize.length, height: assetSize.length)
                .clipped()

            Text(title)
                .pretendardCustomFont(textStyle: .headingMedium)
                .foregroundStyle(Colors.gray900)
                .multilineTextAlignment(textAlignment)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .padding(.top, Spacing.spacing200)

            Text(description)
                .pretendardCustomFont(textStyle: .bodyLarge)
                .foregroundStyle(Colors.gray700)
                .multilineTextAlignment(textAlignment)
                .frame(maxWidth: .infinity, alignment: frameAlignment)
                .padding(.top, Spacing.spacing200)

            if let bottomContent {
                BottomArea(content: bottomContent)
                    .padding(.top, Spacing.spacing250)
            }
        }
        .padding(.horizontal, Spacing.spacing450)
        .padding(.top, assetSize.topPadding)
        .padding(.bottom, Spacing.spacing500)
        .frame(maxWidth: .infinity)
        .background(.clear)
    }

    // MARK: - Private

    private var contentAlignment: HorizontalAlignment {
        layoutType == .center ? .center : .leading
    }

    private var frameAlignment: Alignment {
        layoutType == .center ? .center : .leading
    }

    private var textAlignment: TextAlignment {
        layoutType == .center ? .center : .leading
    }
}

// MARK: - BottomArea

private extension TopHero {
    struct BottomArea: View {
        let content: BottomContent

        var body: some View {
            switch content {
            case let .single(title, action):
                BangawoButton(title, variant: .solid, size: .medium, widthType: .maxWidth, action: action)

            case let .dual(leadingTitle, leadingAction, trailingTitle, trailingAction):
                HStack(spacing: Spacing.spacing200) {
                    BangawoButton(leadingTitle, variant: .weak, size: .medium, widthType: .maxWidth, action: leadingAction)
                    BangawoButton(trailingTitle, variant: .solid, size: .medium, widthType: .maxWidth, action: trailingAction)
                }
            }
        }
    }
}

// MARK: - AssetSize Token Mapping

private extension TopHero.AssetSize {
    var length: CGFloat {
        switch self {
        case .large: return 104
        case .small: return 64
        }
    }

    var topPadding: CGFloat {
        switch self {
        case .large: return Spacing.spacing300  // 16
        case .small: return Spacing.spacing400  // 24
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
                layoutType: .center
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요",
                bottomContent: .single(title: "동의하고 시작하기", action: {})
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요",
                layoutType: .center,
                bottomContent: .single(title: "동의하고 시작하기", action: {})
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "64 에셋 / 왼쪽 정렬",
                description: "에셋 크기가 64일 때 상단 패딩은 24",
                assetSize: .small
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "64 에셋 / 버튼 포함",
                description: "에셋 크기가 64일 때 상단 패딩은 24",
                layoutType: .center,
                assetSize: .small,
                bottomContent: .single(title: "확인", action: {})
            )

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "버튼 2개",
                description: "좌측 weak, 우측 solid",
                bottomContent: .dual(
                    leadingTitle: "나중에",
                    leadingAction: {},
                    trailingTitle: "동의하고 시작하기",
                    trailingAction: {}
                )
            )
        }
    }
}
