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

    // MARK: - Properties

    private let asset: Image
    private let title: String
    private let description: String
    private var layoutType: LayoutType = .leading
    private var assetSize: AssetSize = .large
    private var singleButtonTitle: String? = nil
    private var singleButtonAction: (() -> Void)? = nil
    private var leadingButtonTitle: String? = nil
    private var leadingButtonAction: (() -> Void)? = nil
    private var trailingButtonTitle: String? = nil
    private var trailingButtonAction: (() -> Void)? = nil

    // MARK: - Init

    public init(
        asset: Image,
        title: String,
        description: String
    ) {
        self.asset = asset
        self.title = title
        self.description = description
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

            if let singleButtonTitle, let singleButtonAction {
                BangawoButton(singleButtonTitle, variant: .solid, size: .medium, action: singleButtonAction)
                    .buttonWidth(.maxWidth)
                    .padding(.top, Spacing.spacing250)
            } else if let leadingButtonTitle, let leadingButtonAction,
                      let trailingButtonTitle, let trailingButtonAction {
                HStack(spacing: Spacing.spacing200) {
                    BangawoButton(leadingButtonTitle, variant: .weak, size: .medium, action: leadingButtonAction)
                        .buttonWidth(.maxWidth)
                    BangawoButton(trailingButtonTitle, variant: .solid, size: .medium, action: trailingButtonAction)
                        .buttonWidth(.maxWidth)
                }
                .padding(.top, Spacing.spacing250)
            }
        }
        .padding(.horizontal, Spacing.spacing450)
        .padding(.top, assetSize.topPadding)
        .padding(.bottom, Spacing.spacing500)
        .frame(maxWidth: .infinity)
        .background(.clear)
    }

    // MARK: - Modifiers

    public func layout(_ type: LayoutType) -> Self {
        var copy = self
        copy.layoutType = type
        return copy
    }

    public func assetSize(_ size: AssetSize) -> Self {
        var copy = self
        copy.assetSize = size
        return copy
    }

    public func bottomButton(title: String, action: @escaping () -> Void) -> Self {
        var copy = self
        copy.singleButtonTitle = title
        copy.singleButtonAction = action
        return copy
    }

    public func bottomButtons(
        leadingTitle: String,
        leadingAction: @escaping () -> Void,
        trailingTitle: String,
        trailingAction: @escaping () -> Void
    ) -> Self {
        var copy = self
        copy.leadingButtonTitle = leadingTitle
        copy.leadingButtonAction = leadingAction
        copy.trailingButtonTitle = trailingTitle
        copy.trailingButtonAction = trailingAction
        return copy
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
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요"
            )
            .layout(.center)

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요"
            )
            .bottomButton(title: "동의하고 시작하기") {}

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "편리한 이용을 위해\n약관 동의가 필요해요",
                description: "서비스 이용을 위해 아래 약관에 동의해 주세요"
            )
            .layout(.center)
            .bottomButton(title: "동의하고 시작하기") {}

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "64 에셋 / 왼쪽 정렬",
                description: "에셋 크기가 64일 때 상단 패딩은 24"
            )
            .assetSize(.small)

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "64 에셋 / 버튼 포함",
                description: "에셋 크기가 64일 때 상단 패딩은 24"
            )
            .assetSize(.small)
            .layout(.center)
            .bottomButton(title: "확인") {}

            Divider()

            TopHero(
                asset: Image(systemName: "person.circle.fill"),
                title: "버튼 2개",
                description: "좌측 weak, 우측 solid"
            )
            .bottomButtons(
                leadingTitle: "나중에",
                leadingAction: {},
                trailingTitle: "동의하고 시작하기",
                trailingAction: {}
            )
        }
    }
}
