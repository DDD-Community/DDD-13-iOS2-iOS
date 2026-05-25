//
//  View+BottomSheetNative.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        header: BottomSheet<Content>.HeaderConfig? = nil,
        contentVerticalPadding: CGFloat = 0,
        buttons: [BottomSheet<Content>.ButtonConfig] = [],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented) {
            NativeSheetContent(
                header: header,
                contentVerticalPadding: contentVerticalPadding,
                buttons: buttons,
                content: content
            )
        }
    }
}

private enum Metric {
    static let contentSlotHeight: CGFloat = 230
    static let handleBarWidth: CGFloat = 48
    static let handleBarHeight: CGFloat = 4
}

// MARK: - NativeSheetContent

private struct NativeSheetContent<Content: View>: View {
    let header: BottomSheet<Content>.HeaderConfig?
    let contentVerticalPadding: CGFloat
    let buttons: [BottomSheet<Content>.ButtonConfig]
    let content: () -> Content

    @State private var isKeyboardVisible = false
    @State private var contentNaturalHeight: CGFloat = 0
    @State private var scrollViewport: CGFloat = 0

    private var detents: Set<PresentationDetent> {
        contentNaturalHeight > scrollViewport
            ? [.(0.5), .fraction(0.9)]
            : [.fraction(0.5)]
    }

    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Colors.gray300)
                .frame(width: Metric.handleBarWidth, height: Metric.handleBarHeight)
                .padding(.top, Spacing.spacing300)
            if let header {
                HeaderRow(config: header)
            }
            ScrollView {
                content()
                    .padding(.horizontal, Spacing.spacing400)
                    .padding(.vertical, contentVerticalPadding)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .onChange(of: geo.size.height, initial: true) { _, h in
                                    contentNaturalHeight = h
                                }
                        }
                    )
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.size.height, initial: true) { _, h in
                            scrollViewport = h
                        }
                }
            )
            .frame(minHeight: Metric.contentSlotHeight, maxHeight: .infinity)
            .scrollBounceBehavior(.basedOnSize)
            if !buttons.isEmpty {
                ButtonRow(buttons: Array(buttons.prefix(2)), isKeyboardVisible: isKeyboardVisible)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .presentationDetents(detents)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Colors.gray00)
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        ) { _ in isKeyboardVisible = true }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        ) { _ in isKeyboardVisible = false }
    }
}

// MARK: - HeaderRow

private extension NativeSheetContent {
    struct HeaderRow: View {
        let config: BottomSheet<Content>.HeaderConfig

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

// MARK: - ButtonRow

private extension NativeSheetContent {
    struct ButtonRow: View {
        let buttons: [BottomSheet<Content>.ButtonConfig]
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
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .bottomSheet(
                    isPresented: $isPresented,
                    header: .init(
                        title: "제목입니다",
                        description: "설명 텍스트가 여기에 표시됩니다.",
                        onClose: { isPresented = false }
                    ),
                    contentVerticalPadding: Spacing.spacing400,
                    buttons: [.init(title: "확인") { isPresented = false }]
                ) {
                    Text("컨텐츠 영역")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
    }
    return Preview()
}

#Preview("헤더 + 버튼 2개") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .bottomSheet(
                    isPresented: $isPresented,
                    header: .init(
                        title: "제목입니다",
                        description: "설명 텍스트가 여기에 표시됩니다.",
                        onClose: { isPresented = false }
                    ),
                    contentVerticalPadding: Spacing.spacing400,
                    buttons: [
                        .init(title: "취소") { isPresented = false },
                        .init(title: "확인") { isPresented = false }
                    ]
                ) {
                    Text("컨텐츠 영역")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
    }
    return Preview()
}



#Preview("키보드 (TextField)") {
    struct Preview: View {
        @State private var isPresented = false
        @State private var text = ""

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .bottomSheet(
                    isPresented: $isPresented,
                    header: .init(title: "키보드 테스트", onClose: { isPresented = false }),
                    contentVerticalPadding: Spacing.spacing400,
                    buttons: [.init(title: "확인") { isPresented = false }]
                ) {
                    TextField("입력하세요", text: $text)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
        }
    }
    return Preview()
}
