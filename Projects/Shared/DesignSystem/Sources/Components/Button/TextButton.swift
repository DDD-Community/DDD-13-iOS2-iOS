//
//  TextButton.swift
//  DesignSystem
//

import SwiftUI

public struct TextButton: View {
    // MARK: - Enums

    public enum ButtonType {
        case textOnly
        case textWithArrow
    }

    public enum Size {
        case large
        case medium
        case small
    }

    // MARK: - Properties

    private let title: String
    private let type: ButtonType
    private let size: Size
    private var isDisabled: Bool = false
    private let action: () -> Void

    @GestureState private var isPressed = false

    // MARK: - Init

    public init(
        _ title: String,
        type: ButtonType = .textOnly,
        size: Size = .medium,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.size = size
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        ButtonContent(
            title: title,
            type: type,
            size: size,
            foregroundColor: foregroundColor,
            isDisabled: isDisabled
        )
        .padding(Spacing.spacing50)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(isPressed ? Colors.grayAlpha200 : .clear)
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .gesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    guard !isDisabled else { return }
                    state = true
                }
                .onEnded { _ in
                    guard !isDisabled else { return }
                    action()
                }
        )
    }

    // MARK: - Modifiers

    /// 비활성 상태
    public func disabled(_ isDisabled: Bool) -> Self {
        var copy = self
        copy.isDisabled = isDisabled
        return copy
    }

    // MARK: - Computed

    private var foregroundColor: Color {
        isDisabled ? Colors.gray500 : Colors.gray700
    }
}

// MARK: - ButtonContent

private extension TextButton {
    struct ButtonContent: View {
        let title: String
        let type: ButtonType
        let size: Size
        let foregroundColor: Color
        let isDisabled: Bool

        var body: some View {
            HStack(spacing: 0) {
                Text(title)
                    .pretendardCustomFont(textStyle: size.font)
                    .foregroundStyle(foregroundColor)
                    .padding(.vertical, Spacing.spacing50)

                if type == .textWithArrow {
                    ArrowIcon(size: size, isDisabled: isDisabled)
                }
            }
        }
    }

    struct ArrowIcon: View {
        let size: Size
        let isDisabled: Bool

        var body: some View {
            (isDisabled ? Image.Asset.icArrowRightDisabled24 : Image.Asset.icArrowRight24)
                .resizable()
                .frame(width: size.iconSize, height: size.iconSize)
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                Text("TextOnly / Sizes")
                    .font(.headline)

                TextButton("Large Text", size: .large) {}
                TextButton("Medium Text", size: .medium) {}
                TextButton("Small Text", size: .small) {}
            }

            Divider()

            Group {
                Text("TextWithArrow / Sizes")
                    .font(.headline)

                TextButton("Large Arrow", type: .textWithArrow, size: .large) {}
                TextButton("Medium Arrow", type: .textWithArrow, size: .medium) {}
                TextButton("Small Arrow", type: .textWithArrow, size: .small) {}
            }

            Divider()

            Group {
                Text("Disabled")
                    .font(.headline)

                TextButton("Disabled TextOnly", size: .medium) {}
                    .disabled(true)

                TextButton("Disabled TextWithArrow", type: .textWithArrow, size: .medium) {}
                    .disabled(true)
            }
        }
        .padding(24)
    }
}
