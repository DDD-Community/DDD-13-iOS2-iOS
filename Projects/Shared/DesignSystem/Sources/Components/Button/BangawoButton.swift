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

    @GestureState private var isPressed = false

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

    // MARK: - Modifiers

    /// 로딩 상태
    public func loading(_ isLoading: Bool) -> Self {
        var copy = self
        copy.isLoading = isLoading
        return copy
    }

    /// 비활성 상태
    public func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy.isDisabled = isDisabled
        return copy
    }

    /// 버튼 가로 너비 타입
    public func buttonWidth(_ type: WidthType) -> Self {
        var copy = self
        copy.widthType = type
        return copy
    }

    /// 키보드 올라왔을 때 레이아웃 — full width + radius 0 + body/large 타이포
    public func keyboardAttached() -> Self {
        var copy = self
        copy.isKeyboardAttached = true
        copy.widthType = .maxWidth
        return copy
    }

    /// 배경색 커스텀 지정
    public func buttonBackgroundColor(_ color: Color) -> Self {
        var copy = self
        copy.customBackgroundColor = color
        return copy
    }

    // MARK: - Label

    // 라벨 텍스트 색상
    private var foregroundColor: Color {
        if isDisabled { return Colors.gray500 }
        return variant == .solid ? Colors.gray00 : Colors.gray800
    }

    // 로딩 인디케이터 색상
    private var indicatorTintColor: Color {
        variant.indicatorColor
    }

    // 라벨 타이포
    private var effectiveFont: CustomSizeFont {
        isKeyboardAttached ? .bodyLarge : size.font
    }

    // 로딩 인디케이터 크기
    private var indicatorSize: CGFloat {
        isKeyboardAttached
            ? Spacing.spacing800 - 2 * Spacing.spacing300
            : size.minHeight - 2 * size.verticalPadding
    }

    // MARK: - Layout

    // 배경색
    private var currentBackground: Color {
        if let custom = customBackgroundColor { return custom }
        if isDisabled { return variant.disabledBackground }
        if isLoading { return variant.enabledBackground }
        return isPressed ? variant.pressedBackground : variant.enabledBackground
    }

    // 수직 내부 패딩
    private var effectiveVerticalPadding: CGFloat {
        isKeyboardAttached ? Spacing.spacing300 : size.verticalPadding
    }

    // 수평 내부 패딩
    private var effectiveHorizontalPadding: CGFloat {
        isKeyboardAttached ? Spacing.spacing400 : size.horizontalPadding
    }

    // 최소 높이
    private var effectiveMinHeight: CGFloat {
        isKeyboardAttached ? Spacing.spacing800 : size.minHeight
    }

    // 모서리 반경
    private var effectiveCornerRadius: CGFloat {
        isKeyboardAttached ? 0 : size.cornerRadius
    }

    // 최대 너비
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
