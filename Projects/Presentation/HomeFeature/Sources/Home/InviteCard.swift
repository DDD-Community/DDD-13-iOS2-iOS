//
//  InviteCard.swift
//  Presentation
//

import SwiftUI

import DesignSystem

// MARK: - InviteCard

struct InviteCard: View {
    let design: HomeFeature.InviteCardDesign
    let onClose: () -> Void
    let onInvite: () -> Void

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius500
    }

    var body: some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: Metric.cornerRadius)
                    .stroke(Colors.grayAlpha100, lineWidth: BorderWidth.borderWidth100)
            )
    }

    @ViewBuilder
    private var content: some View {
        switch design {
        case .design1:
            InviteCardCompact(onClose: onClose, onInvite: onInvite)

        case .design2:
            InviteCardLarge(onClose: onClose, onInvite: onInvite)
        }
    }
}

// MARK: - Close Button

private struct InviteCloseButton: View {
    let onClose: () -> Void

    private enum Metric {
        static let topPadding: CGFloat = 20
    }

    var body: some View {
        Button(action: onClose) {
            Image.Asset.icClose24
                .renderingMode(.template)
                .foregroundStyle(Colors.gray600)
        }
        .buttonStyle(.plain)
        .padding(.top, Metric.topPadding)
        .padding(.trailing, Spacing.spacing400)
    }
}

// MARK: - Design 1 (Compact)

private struct InviteCardCompact: View {
    let onClose: () -> Void
    let onInvite: () -> Void

    var body: some View {
        Image.Asset.imgInviteBackground1
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                InviteCloseButton(onClose: onClose)
            }
            .overlay(alignment: .bottom) {
                bottomElement
                    .padding([.horizontal, .bottom], Spacing.spacing300)
            }
    }

    private var bottomElement: some View {
        HStack(spacing: Spacing.spacing250) {
            VStack(alignment: .leading, spacing: Spacing.spacing100) {
                Text("친구 초대하러가기")
                    .pretendardFont(family: .SemiBold, size: Typography.typographySize100)
                    .kerning(Typography.typographyLetterSpacing000 * Typography.typographySize100)
                    .lineSpacing(Typography.typographyLineHeight50 - Typography.typographySize100)
                    .foregroundStyle(Colors.gray900)

                BangawoText("친구와 링크 공유하고 모일 곳을 정해봐요", textStyle: .bodyXSmall)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            BangawoButton("초대하기", variant: .weak, size: .xsmall) {
                onInvite()
            }
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing300)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .fill(Colors.neutralAlpha500)
        )
    }
}

// MARK: - Design 2 (Large CTA)

private struct InviteCardLarge: View {
    let onClose: () -> Void
    let onInvite: () -> Void

    var body: some View {
        Image.Asset.imgInviteBackground2
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .overlay(alignment: .topTrailing) {
                InviteCloseButton(onClose: onClose)
            }
            .overlay(alignment: .bottom) {
                bottomElement
                    .padding(.horizontal, Spacing.spacing400)
                    .padding(.bottom, Spacing.spacing300)
            }
    }

    private var bottomElement: some View {
        VStack(spacing: Spacing.spacing500) {
            VStack(spacing: Spacing.spacing100) {
                BangawoText("친구 초대하고 장소 함께 고르기", textStyle: .titleMediumEmphasized)
                    .foregroundStyle(Colors.gray900)

                BangawoText("우리만의 중간 장소로 모일 곳을 찾아봐요!", textStyle: .bodySmall)
                    .foregroundStyle(Colors.gray700)
            }
            .multilineTextAlignment(.center)

            BangawoButton("초대하기", variant: .weak, size: .medium, widthType: .maxWidth) {
                onInvite()
            }
        }
    }
}
