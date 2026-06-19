//
//  TopPage.swift
//  DesignSystem
//

import SwiftUI

/// 페이지 상단 영역을 구성하는 헤더 컴포넌트.
///
/// 3D 에셋(topArea), 타이틀·설명·버튼(titleArea), 뱃지(lowerArea)를 수직으로 정렬합니다.
public struct TopPage: View {
    // MARK: - Properties

    private let d3Asset: Asset.D3
    private let title: String
    private let description: String
    private let buttonTitle: String
    private let buttonVariant: BangawoButton.Variant
    private let buttonSize: BangawoButton.Size
    private let showLowerArea: Bool
    private let badgeLabel: String
    private let badgeLeadingIcon: Image?
    private let buttonAction: () -> Void

    // MARK: - Init

    public init(
        d3Asset: Asset.D3,
        title: String,
        description: String,
        buttonTitle: String,
        buttonVariant: BangawoButton.Variant = .weak,
        buttonSize: BangawoButton.Size = .small,
        showLowerArea: Bool = true,
        badgeLabel: String = "",
        badgeLeadingIcon: Image? = nil,
        buttonAction: @escaping () -> Void
    ) {
        self.d3Asset = d3Asset
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.buttonVariant = buttonVariant
        self.buttonSize = buttonSize
        self.showLowerArea = showLowerArea
        self.badgeLabel = badgeLabel
        self.badgeLeadingIcon = badgeLeadingIcon
        self.buttonAction = buttonAction
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopArea(d3Asset: d3Asset)

            TitleArea(
                title: title,
                description: description,
                buttonTitle: buttonTitle,
                buttonVariant: buttonVariant,
                buttonSize: buttonSize,
                buttonAction: buttonAction
            )

            if showLowerArea {
                LowerArea(label: badgeLabel, leadingIcon: badgeLeadingIcon)
            }
        }
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TopArea

private extension TopPage {
    struct TopArea: View {
        let d3Asset: Asset.D3

        /// d3Asset : 3D 에셋
        init(d3Asset: Asset.D3) {
            self.d3Asset = d3Asset
        }

        var body: some View {
            Asset(assetType: .d3(d3Asset), size: .s64)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - TitleArea

private extension TopPage {
    struct TitleArea: View {
        let title: String
        let description: String
        let buttonTitle: String
        let buttonVariant: BangawoButton.Variant
        let buttonSize: BangawoButton.Size
        let buttonAction: () -> Void

        var body: some View {
            HStack(alignment: .center, spacing: Spacing.spacing400) {
                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    BangawoText(title, textStyle: .headingSmall)
                        .foregroundStyle(Colors.gray900)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    BangawoText(description, textStyle: .bodySmall)
                        .foregroundStyle(Colors.gray700)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                BangawoButton(
                    buttonTitle,
                    variant: buttonVariant,
                    size: buttonSize,
                    action: buttonAction
                )
            }
        }
    }
}

// MARK: - LowerArea

private extension TopPage {
    struct LowerArea: View {
        let label: String
        let leadingIcon: Image?

        var body: some View {
            Badge(
                label,
                leadingIcon: leadingIcon,
                showLeadingIcon: leadingIcon != nil,
                showTrailingIcon: false,
                variant: .outline,
                size: .small
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.spacing250)
        }
    }
}

#Preview {
    BangawoPreview {
        ScrollView {
            VStack(spacing: 48) {
                TopPage(
                    d3Asset: .avatarPlaceholder,
                    title: "모임 정보를\n확인해 보세요",
                    description: "참여 중인 모임의 상세 정보예요",
                    buttonTitle: "수정",
                    badgeLabel: "강남역 인근",
                    badgeLeadingIcon: Image.Asset.icStar24,
                    buttonAction: {}
                )

                Divider()

                TopPage(
                    d3Asset: .avatarPlaceholder,
                    title: "모임 정보를\n확인해 보세요",
                    description: "참여 중인 모임의 상세 정보예요",
                    buttonTitle: "초대하기",
                    buttonVariant: .solid,
                    buttonSize: .medium,
                    badgeLabel: "강남역 인근",
                    badgeLeadingIcon: Image.Asset.icStar24,
                    buttonAction: {}
                )

                Divider()

                TopPage(
                    d3Asset: .avatarPlaceholder,
                    title: "모임 정보를\n확인해 보세요",
                    description: "참여 중인 모임의 상세 정보예요",
                    buttonTitle: "수정",
                    showLowerArea: false,
                    buttonAction: {}
                )
            }
        }
    }
}
