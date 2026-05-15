//
//  BangawoButton.swift
//  DesignSystem
//

import SwiftUI

public struct BangawoButton: View {
    // MARK: - Enums

    public enum Variant {
        case weak
        case solid
    }

    public enum Size {
        case xsmall
        case small
        case medium
        case large
    }

    public enum WidthType {
        case `default`
        case maxWidth
    }

    // MARK: - Properties

    private let title: String
    private let variant: Variant
    private let size: Size
    private var widthType: WidthType = .default
    private var isLoading: Bool = false
    private var isDisabled: Bool = false
    private var isKeyboardAttached: Bool = false
    private var customBackgroundColor: Color? = nil
    private let action: () -> Void

    // MARK: - Init

    public init(
        _ title: String,
        variant: Variant = .solid,
        size: Size = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: {
            guard !isDisabled, !isLoading else { return }
            action()
        }) {
            ButtonContent(
                title: title,
                isLoading: isLoading,
                indicatorTintColor: indicatorTintColor,
                indicatorSize: indicatorSize,
                effectiveFont: effectiveFont,
                foregroundColor: foregroundColor,
                widthType: widthType
            )
        }
        .buttonStyle(
            BangawoButtonStyle(
                variant: variant,
                size: size,
                widthType: widthType,
                isDisabled: isDisabled,
                isLoading: isLoading,
                isKeyboardAttached: isKeyboardAttached,
                customBackgroundColor: customBackgroundColor
            )
        )
    }

    // MARK: - Modifiers

    public func loading(_ isLoading: Bool) -> Self {
        var copy = self
        copy.isLoading = isLoading
        return copy
    }

    public func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy.isDisabled = isDisabled
        return copy
    }

    public func buttonWidth(_ type: WidthType) -> Self {
        var copy = self
        copy.widthType = type
        return copy
    }

    /// 키보드가 올라왔을 때 적용. 디바이스 full width + radius 0 + 고유 size 스펙으로 전환.
    public func keyboardAttached() -> Self {
        var copy = self
        copy.isKeyboardAttached = true
        copy.widthType = .maxWidth
        return copy
    }

    public func buttonBackgroundColor(_ color: Color) -> Self {
        var copy = self
        copy.customBackgroundColor = color
        return copy
    }

    // MARK: - Private

    private var foregroundColor: Color {
        let base: Color = (isKeyboardAttached || variant == .solid) ? Colors.gray00 : Colors.gray800
        return isDisabled ? base.opacity(Opacity.opacity500) : base
    }

    private var indicatorTintColor: Color {
        isKeyboardAttached ? Colors.gray00 : variant.indicatorColor
    }

    private var effectiveFont: CustomSizeFont {
        isKeyboardAttached ? .titleMediumEmphasized : size.font
    }

    private var indicatorSize: CGFloat {
        isKeyboardAttached
            ? Spacing.spacing800 - 2 * Spacing.spacing300
            : size.minHeight - 2 * size.verticalPadding
    }
}

// MARK: - ButtonContent

private extension BangawoButton {
    struct ButtonContent: View {
        let title: String
        let isLoading: Bool
        let indicatorTintColor: Color
        let indicatorSize: CGFloat
        let effectiveFont: CustomSizeFont
        let foregroundColor: Color
        let widthType: WidthType

        var body: some View {
            ZStack {
                Text(title)
                    .multilineTextAlignment(.center)
                    .pretendardCustomFont(textStyle: effectiveFont)
                    .foregroundStyle(foregroundColor)
                    .frame(maxWidth: widthType == .default ? nil : .infinity)
                    .opacity(isLoading ? 0 : 1)

                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(indicatorTintColor)
                    .frame(width: indicatorSize, height: indicatorSize)
                    .opacity(isLoading ? 1 : 0)
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                Text("Solid / Sizes")
                    .font(.headline)

                BangawoButton("XSmall", size: .xsmall) {}
                BangawoButton("Small", size: .small) {}
                BangawoButton("Medium", size: .medium) {}
                BangawoButton("Large", size: .large) {}
            }

            Divider()

            Group {
                Text("Weak / Sizes")
                    .font(.headline)

                BangawoButton("XSmall", variant: .weak, size: .xsmall) {}
                BangawoButton("Small", variant: .weak, size: .small) {}
                BangawoButton("Medium", variant: .weak, size: .medium) {}
                BangawoButton("Large", variant: .weak, size: .large) {}
            }

            Divider()

            Group {
                Text("States")
                    .font(.headline)

                BangawoButton("Loading", size: .medium) {}
                    .loading(true)

                BangawoButton("Disabled Solid", size: .medium) {}
                    .disabled(true)

                BangawoButton("Disabled Weak", variant: .weak, size: .medium) {}
                    .disabled(true)
            }

            Divider()

            Group {
                Text("Width Types")
                    .font(.headline)

                BangawoButton("MaxWidth", size: .medium) {}
                    .buttonWidth(.maxWidth)

                BangawoButton("Keyboard Attached", size: .medium) {}
                    .keyboardAttached()
            }
        }
        .padding(24)
    }
}
