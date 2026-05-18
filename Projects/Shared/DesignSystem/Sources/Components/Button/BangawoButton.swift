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
    private let widthType: WidthType
    private let isLoading: Bool
    private let isDisabled: Bool
    private let isKeyboardAttached: Bool
    private let customBackgroundColor: Color?
    private let action: () -> Void

    @GestureState private var isPressed = false

    // MARK: - Init

    public init(
        _ title: String,
        variant: Variant = .solid,
        size: Size = .medium,
        widthType: WidthType = .default,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        isKeyboardAttached: Bool = false,
        customBackgroundColor: Color? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.widthType = widthType
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.isKeyboardAttached = isKeyboardAttached
        self.customBackgroundColor = customBackgroundColor
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        ButtonContent(
            title: title,
            isLoading: isLoading,
            indicatorTintColor: indicatorTintColor,
            indicatorSize: indicatorSize,
            effectiveFont: effectiveFont,
            foregroundColor: foregroundColor,
            widthType: widthType
        )
        .padding(.vertical, effectiveVerticalPadding)
        .padding(.horizontal, effectiveHorizontalPadding)
        .frame(maxWidth: effectiveMaxWidth, minHeight: effectiveMinHeight)
        .background(currentBackground)
        .clipShape(RoundedRectangle(cornerRadius: effectiveCornerRadius))
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    guard !isDisabled, !isLoading else { return }

                    state = true
                }
                .onEnded { _ in
                    guard !isDisabled, !isLoading else { return }

                    action()
                }
        )
    }

    // MARK: - Label

    private var foregroundColor: Color {
        if isDisabled { return Colors.gray500 }
        return variant == .solid ? Colors.gray00 : Colors.gray800
    }

    private var indicatorTintColor: Color {
        variant.indicatorColor
    }

    private var effectiveFont: CustomSizeFont {
        isKeyboardAttached ? .bodyLarge : size.font
    }

    private var indicatorSize: CGFloat {
        isKeyboardAttached
            ? Spacing.spacing800 - 2 * Spacing.spacing300
            : size.minHeight - 2 * size.verticalPadding
    }

    // MARK: - Layout

    private var currentBackground: Color {
        if let custom = customBackgroundColor { return custom }
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

                BangawoButton("Loading", size: .medium, isLoading: true) {}
                BangawoButton("Disabled Solid", size: .medium, isDisabled: true) {}
                BangawoButton("Disabled Weak", variant: .weak, size: .medium, isDisabled: true) {}
            }

            Divider()

            Group {
                Text("Width Types")
                    .font(.headline)

                BangawoButton("MaxWidth", size: .medium, widthType: .maxWidth) {}
                BangawoButton("Keyboard Attached", size: .medium, isKeyboardAttached: true) {}
            }
        }
        .padding(24)
    }
}
