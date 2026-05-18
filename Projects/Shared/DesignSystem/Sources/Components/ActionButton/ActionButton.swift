//
//  ActionButton.swift
//  DesignSystem
//

import SwiftUI

public struct ActionButton: View {
    // MARK: - Properties

    private let buttonLayout: ButtonLayout
    private let upperContent: UpperContent?
    private let lowerContent: LowerContent?

    // MARK: - Init

    public init(
        buttonLayout: ButtonLayout,
        upperContent: UpperContent? = nil,
        lowerContent: LowerContent? = nil
    ) {
        self.buttonLayout = buttonLayout
        self.upperContent = upperContent
        self.lowerContent = lowerContent
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            if let upper = upperContent {
                UpperArea(content: upper)
            }

            ButtonArea(layout: buttonLayout)

            if let lower = lowerContent {
                LowerArea(content: lower)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - UpperArea

private extension ActionButton {
    struct UpperArea: View {
        let content: UpperContent

        var body: some View {
            Group {
                switch content {
                case let .snackBar(message, buttonTitle, action):
                    SnackBar(message, buttonTitle: buttonTitle, action: action)

                case let .toast(message):
                    Toast(message)

                case let .description(text):
                    Text(text)
                        .pretendardCustomFont(textStyle: .bodyLarge)
                        .foregroundStyle(Colors.gray700)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.bottom, Spacing.spacing400)
            .padding(.horizontal, Spacing.spacing450)
        }
    }
}

// MARK: - ButtonArea

private extension ActionButton {
    struct ButtonArea: View {
        let layout: ButtonLayout

        var body: some View {
            switch layout {
            case let .single(title, action):
                BangawoButton(title, variant: .solid, size: .large, widthType: .maxWidth, action: action)
                    .padding(.horizontal, Spacing.spacing450)

            case let .dual(primaryTitle, primaryAction, secondaryTitle, secondaryAction, arrangement):
                DualButtonArea(
                    primaryTitle: primaryTitle,
                    primaryAction: primaryAction,
                    secondaryTitle: secondaryTitle,
                    secondaryAction: secondaryAction,
                    arrangement: arrangement
                )
            }
        }
    }

    struct DualButtonArea: View {
        let primaryTitle: String
        let primaryAction: () -> Void
        let secondaryTitle: String
        let secondaryAction: () -> Void
        let arrangement: DualArrangement

        var body: some View {
            switch arrangement {
            case .vertical:
                VStack(spacing: Spacing.spacing200) {
                    BangawoButton(primaryTitle, variant: .solid, size: .large, widthType: .maxWidth, action: primaryAction)
                    BangawoButton(secondaryTitle, variant: .weak, size: .large, widthType: .maxWidth, action: secondaryAction)
                }
                .padding(.horizontal, Spacing.spacing450)

            case .horizontal:
                HStack(spacing: Spacing.spacing200) {
                    BangawoButton(secondaryTitle, variant: .weak, size: .large, widthType: .maxWidth, action: secondaryAction)
                    BangawoButton(primaryTitle, variant: .solid, size: .large, widthType: .maxWidth, action: primaryAction)
                }
                .padding(.horizontal, Spacing.spacing450)
            }
        }
    }
}

// MARK: - LowerArea

private extension ActionButton {
    struct LowerArea: View {
        let content: LowerContent

        var body: some View {
            TextButton(content.title, type: content.type, action: content.action)
                .padding(.top, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing200)
                .padding(.horizontal, Spacing.spacing450)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 40) {
            Group {
                Text("Single Button")
                    .font(.headline)

                ActionButton(buttonLayout: .single(title: "확인", action: {}))
            }

            Divider()

            Group {
                Text("Single + Description")
                    .font(.headline)

                ActionButton(
                    buttonLayout: .single(title: "확인", action: {}),
                    upperContent: .description("안내 문구가 여기에 표시됩니다")
                )
            }

            Divider()

            Group {
                Text("Single + SnackBar + LowerArea")
                    .font(.headline)

                ActionButton(
                    buttonLayout: .single(title: "확인", action: {}),
                    upperContent: .snackBar(message: "안내 메시지입니다", buttonTitle: "닫기", action: {}),
                    lowerContent: .init("더 알아보기", type: .textWithArrow, action: {})
                )
            }

            Divider()

            Group {
                Text("Dual Vertical")
                    .font(.headline)

                ActionButton(
                    buttonLayout: .dual(
                        primaryTitle: "확인",
                        primaryAction: {},
                        secondaryTitle: "취소",
                        secondaryAction: {},
                        arrangement: .vertical
                    ),
                    upperContent: .toast(message: "토스트 메시지입니다"),
                    lowerContent: .init("건너뛰기", action: {})
                )
            }

            Divider()

            Group {
                Text("Dual Horizontal")
                    .font(.headline)

                ActionButton(buttonLayout: .dual(
                    primaryTitle: "확인",
                    primaryAction: {},
                    secondaryTitle: "취소",
                    secondaryAction: {},
                    arrangement: .horizontal
                ))
            }
        }
        .padding(.vertical, 24)
    }
}
