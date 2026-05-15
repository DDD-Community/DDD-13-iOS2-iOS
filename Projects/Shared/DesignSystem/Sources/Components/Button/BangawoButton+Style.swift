//
//  BangawoButton+Style.swift
//  DesignSystem
//

import SwiftUI

struct BangawoButtonStyle: ButtonStyle {
    let variant: BangawoButton.Variant
    let size: BangawoButton.Size
    let widthType: BangawoButton.WidthType
    let isDisabled: Bool
    let isLoading: Bool
    let isKeyboardAttached: Bool
    let customBackgroundColor: Color?

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, effectiveVerticalPadding)
            .padding(.horizontal, effectiveHorizontalPadding)
            .frame(maxWidth: effectiveMaxWidth, minHeight: effectiveMinHeight)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: effectiveCornerRadius))
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isKeyboardAttached {
            return isDisabled
                ? Colors.grayAlpha800.opacity(Opacity.opacity400)
                : Colors.grayAlpha800
        }

        if let custom = customBackgroundColor {
            return isDisabled ? custom.opacity(Opacity.opacity400) : custom
        }

        if isDisabled { return variant.disabledBackground }
        if isLoading { return variant.enabledBackground }
        return isPressed ? variant.pressedBackground : variant.enabledBackground
    }

    private var effectiveVerticalPadding: CGFloat {
        isKeyboardAttached ? Spacing.spacing300 : size.verticalPadding
    }

    private var effectiveHorizontalPadding: CGFloat {
        isKeyboardAttached ? Spacing.spacing400 : size.horizontalPadding
    }

    private var effectiveMinHeight: CGFloat {
        isKeyboardAttached ? Spacing.spacing800 : size.minHeight
    }

    private var effectiveCornerRadius: CGFloat {
        isKeyboardAttached ? 0 : size.cornerRadius
    }

    private var effectiveMaxWidth: CGFloat? {
        if isKeyboardAttached { return UIScreen.screenWidth }
        switch widthType {
        case .default: return nil
        case .maxWidth: return .infinity
        }
    }
}
