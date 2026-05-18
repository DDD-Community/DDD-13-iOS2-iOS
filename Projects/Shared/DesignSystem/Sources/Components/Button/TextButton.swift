//
//  TextButton.swift
//  DesignSystem
//

import SwiftUI

public struct TextButton: View {
    // MARK: - Properties

    private let title: String
    private let type: ButtonType
    private let size: Size
    private let isDisabled: Bool
    private let action: () -> Void

    @GestureState private var isPressed = false

    // MARK: - Init

    public init(
        _ title: String,
        type: ButtonType = .textOnly,
        size: Size = .medium,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.size = size
        self.isDisabled = isDisabled
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        ButtonContent(
            title: title,
            type: type,
            size: size,
            foregroundColor: foregroundColor
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

    // MARK: - Computed

    private var foregroundColor: Color {
        isDisabled ? Colors.gray500 : Colors.gray600
    }
}

// MARK: - ButtonContent

private extension TextButton {
    struct ButtonContent: View {
        let title: String
        let type: ButtonType
        let size: Size
        let foregroundColor: Color

        var body: some View {
            HStack(spacing: 0) {
                BangawoText(title, textStyle: size.font)
                    .foregroundStyle(foregroundColor)
                    .padding(.vertical, Spacing.spacing50)

                if type == .textWithArrow {
                    ArrowIcon(size: size, foregroundColor: foregroundColor)
                }
            }
        }
    }

    struct ArrowIcon: View {
        let size: Size
        let foregroundColor: Color

        var body: some View {
            Image.Asset.icArrowSmallRight24
                .resizable()
                .frame(width: size.iconSize, height: size.iconSize)
                .foregroundStyle(foregroundColor)
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 24) {
            Group {
                BangawoText("TextOnly / Sizes", textStyle: .titleLarge)

                TextButton("Large Text", size: .large) {}
                TextButton("Medium Text", size: .medium) {}
                TextButton("Small Text", size: .small) {}
            }

            Divider()

            Group {
                BangawoText("TextWithArrow / Sizes", textStyle: .titleLarge)

                TextButton("Large Arrow", type: .textWithArrow, size: .large) {}
                TextButton("Medium Arrow", type: .textWithArrow, size: .medium) {}
                TextButton("Small Arrow", type: .textWithArrow, size: .small) {}
            }

            Divider()

            Group {
                BangawoText("Disabled", textStyle: .titleLarge)

                TextButton("Disabled TextOnly", size: .medium, isDisabled: true) {}
                TextButton("Disabled TextWithArrow", type: .textWithArrow, size: .medium, isDisabled: true) {}
            }
        }
        .padding(24)
    }
}
