//
//  BottomSheet.swift
//  DesignSystem
//

import SwiftUI

private enum Metric {
    static let contentSlotHeight: CGFloat = 230
    static let handleAreaHeight: CGFloat = 20
    static let handleBarWidth: CGFloat = 36
    static let handleBarHeight: CGFloat = 4
    static let containerBottomPadding: CGFloat = 37
}

public struct BottomSheet<Content: View>: View {
    // MARK: - Properties

    private let header: HeaderConfig?
    private let content: () -> Content
    private let contentVerticalPadding: CGFloat
    private let buttons: [ButtonConfig]

    @State private var isKeyboardVisible = false

    // MARK: - Init

    public init(
        header: HeaderConfig? = nil,
        contentVerticalPadding: CGFloat = 0,
        buttons: [ButtonConfig] = [],
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.contentVerticalPadding = contentVerticalPadding
        self.buttons = Array(buttons.prefix(2))
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Colors.gray300)
                    .frame(width: Metric.handleBarWidth, height: Metric.handleBarHeight)
                    .frame(height: Metric.handleAreaHeight)
                if let header {
                    HeaderView(config: header)
                }
                ScrollView {
                    content()
                        .padding(.horizontal, Spacing.spacing400)
                        .padding(.vertical, contentVerticalPadding)
                }
                .frame(minHeight: Metric.contentSlotHeight, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)
                if !buttons.isEmpty {
                    LowerArea(buttons: buttons, isKeyboardVisible: isKeyboardVisible)
                }
            }
            .padding(.bottom, Spacing.spacing300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .bottom)
        }
        .padding(.bottom, Metric.containerBottomPadding)
        .presentationDragIndicator(.hidden)
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        ) { _ in isKeyboardVisible = true }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        ) { _ in isKeyboardVisible = false }
    }
}

// MARK: - SheetContainer

private extension BottomSheet {
    struct SheetContainer<SheetContent: View>: View {
        let content: () -> SheetContent

        var body: some View {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius450)
                .fill(Colors.gray00)
                .shadow(
                    color: BoxShadow.boxShadow400.color,
                    radius: BoxShadow.boxShadow400.blur,
                    x: BoxShadow.boxShadow400.offsetX,
                    y: BoxShadow.boxShadow400.offsetY
                )
                .ignoresSafeArea(edges: .bottom)

                content()
            }
        }
    }
}

// MARK: - HeaderView

private extension BottomSheet {
    struct HeaderView: View {
        let config: HeaderConfig

        var body: some View {
            HStack(alignment: .top, spacing: Spacing.spacing200) {
                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    BangawoText(config.title, textStyle: .titleLarge)
                        .foregroundStyle(Colors.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let description = config.description {
                        BangawoText(description, textStyle: .bodyLarge)
                            .foregroundStyle(Colors.gray700)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if let onClose = config.onClose {
                    Button(action: onClose) {
                        Image.Asset.icClose24
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Colors.gray500)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, Spacing.spacing300)
            .padding(.trailing, Spacing.spacing300)
            .padding(.bottom, Spacing.spacing200)
            .padding(.leading, Spacing.spacing400)
        }
    }
}

// MARK: - LowerArea

private extension BottomSheet {
    struct LowerArea: View {
        let buttons: [ButtonConfig]
        let isKeyboardVisible: Bool

        var body: some View {
            HStack(spacing: isKeyboardVisible ? 0 : 8) {
                buttonContent
            }
            .padding(
                isKeyboardVisible
                    ? EdgeInsets(top: Spacing.spacing200, leading: 0, bottom: 0, trailing: 0)
                    : EdgeInsets(
                        top: Spacing.spacing200,
                        leading: Spacing.spacing400,
                        bottom: Spacing.spacing300,
                        trailing: Spacing.spacing400
                    )
            )
        }

        @ViewBuilder
        private var buttonContent: some View {
            if buttons.count >= 2 {
                BangawoButton(
                    buttons[0].title,
                    variant: .weak,
                    size: .large,
                    widthType: .maxWidth,
                    isKeyboardAttached: isKeyboardVisible,
                    action: buttons[0].action
                )
                BangawoButton(
                    buttons[1].title,
                    variant: .solid,
                    size: .large,
                    widthType: .maxWidth,
                    isKeyboardAttached: isKeyboardVisible,
                    action: buttons[1].action
                )
            } else if let button = buttons.first {
                BangawoButton(
                    button.title,
                    variant: .solid,
                    size: .large,
                    widthType: .maxWidth,
                    isKeyboardAttached: isKeyboardVisible,
                    action: button.action
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("헤더 + 버튼 1개") {
    Color.gray.ignoresSafeArea()
        .bangawoBottomSheet(
            isPresented: .constant(true),
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: {}
            ),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [.init(title: "확인") {}]
        ) {
            Text("컨텐츠 영역")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
}

#Preview("헤더 + 버튼 2개") {
    Color.gray.ignoresSafeArea()
        .bangawoBottomSheet(
            isPresented: .constant(true),
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: {}
            ),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [
                .init(title: "취소") {},
                .init(title: "확인") {}
            ]
        ) {
            Text("컨텐츠 영역")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
}

#Preview("헤더 없음 + 버튼 없음") {
    Color.gray.ignoresSafeArea()
        .bangawoBottomSheet(
            isPresented: .constant(true),
            contentVerticalPadding: Spacing.spacing400
        ) {
            Text("컨텐츠만 있는 시트")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
}

#Preview("콘텐츠 오버플로우 (스크롤)") {
    Color.gray.ignoresSafeArea()
        .bangawoBottomSheet(
            isPresented: .constant(true),
            header: .init(title: "스크롤 테스트", onClose: {}),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [.init(title: "확인") {}]
        ) {
            VStack(spacing: Spacing.spacing200) {
                ForEach(0..<10, id: \.self) { i in
                    Text("항목 \(i + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
}

#Preview("키보드 (TextField)") {
    struct KeyboardPreview: View {
        @State private var isPresented = true
        @State private var text = ""

        var body: some View {
            Color.gray.ignoresSafeArea()
                .bangawoBottomSheet(
                    isPresented: $isPresented,
                    header: .init(title: "키보드 테스트", onClose: {}),
                    contentVerticalPadding: Spacing.spacing400,
                    buttons: [.init(title: "확인") {}]
                ) {
                    TextField("입력하세요", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
        }
    }
    return KeyboardPreview()
}
