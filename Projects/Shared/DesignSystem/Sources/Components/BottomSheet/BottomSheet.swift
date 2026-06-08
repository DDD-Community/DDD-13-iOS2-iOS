//
//  BottomSheet.swift
//  DesignSystem
//

import SwiftUI

private enum Metric {
    static let contentSlotHeight: CGFloat = 230
    static let handleBarWidth: CGFloat = 48
    static let handleBarHeight: CGFloat = 4
    static let containerBottomPadding: CGFloat = 37
}

public struct BottomSheet<Content: View>: View {
    // MARK: - Properties

    private let header: HeaderConfig?
    private let content: () -> Content
    private let primaryButton: ButtonConfig?
    private let secondaryButton: ButtonConfig?
    private let canExpand: Binding<Bool>?

    @State private var isKeyboardVisible = false
    @State private var contentNaturalHeight: CGFloat = 0
    @State private var scrollViewport: CGFloat = 0

    // MARK: - Init

    public init(
        header: HeaderConfig? = nil,
        primaryButton: ButtonConfig? = nil,
        secondaryButton: ButtonConfig? = nil,
        canExpand: Binding<Bool>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.canExpand = canExpand
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        SheetContainer {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Colors.gray300)
                    .frame(width: Metric.handleBarWidth, height: Metric.handleBarHeight)
                    .padding(.top, Spacing.spacing300)
                if let header {
                    HeaderView(config: header)
                }
                ScrollView {
                    content()
                        .padding(.horizontal, Spacing.spacing400)
                        .padding(.top, Spacing.spacing300)
                        .padding(.bottom, Spacing.spacing200)
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.size.height, initial: true) { _, h in
                                        contentNaturalHeight = h
                                        canExpand?.wrappedValue = h > scrollViewport
                                    }
                            }
                        )
                }
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.size.height, initial: true) { _, h in
                                scrollViewport = h
                                canExpand?.wrappedValue = contentNaturalHeight > h
                            }
                    }
                )
                .frame(minHeight: Metric.contentSlotHeight, maxHeight: .infinity)
                .scrollBounceBehavior(.basedOnSize)

                if primaryButton != nil || secondaryButton != nil {
                    LowerArea(
                        primaryButton: primaryButton,
                        secondaryButton: secondaryButton,
                        isKeyboardVisible: isKeyboardVisible
                    )
                }
            }
            .padding(.bottom, Spacing.spacing300)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea(edges: .bottom)
        }
        .ignoresSafeArea(edges: .bottom)
        .padding(.bottom, isKeyboardVisible ? 0 : Metric.containerBottomPadding)
        .padding(.horizontal, isKeyboardVisible ? 0 : Spacing.spacing300)
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
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
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
        let primaryButton: ButtonConfig?
        let secondaryButton: ButtonConfig?
        let isKeyboardVisible: Bool

        var body: some View {
            HStack(spacing: isKeyboardVisible ? 0 : 8) {
                if let secondary = secondaryButton {
                    BangawoButton(
                        secondary.title,
                        variant: .weak,
                        size: .large,
                        widthType: .maxWidth,
                        isDisabled: !secondary.isEnabled,
                        isKeyboardAttached: isKeyboardVisible,
                        action: secondary.action
                    )
                }
                if let primary = primaryButton {
                    BangawoButton(
                        primary.title,
                        variant: .solid,
                        size: .large,
                        widthType: .maxWidth,
                        isDisabled: !primary.isEnabled,
                        isKeyboardAttached: isKeyboardVisible,
                        action: primary.action
                    )
                }
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
    }
}

// MARK: - Preview

#Preview {
    BottomSheet(
        header: .init(
            title: "제목입니다",
            description: "설명 텍스트가 여기에 표시됩니다.",
            onClose: {}
        ),
        primaryButton: .init(title: "확인") {},
        secondaryButton: .init(title: "취소") {}
    ) {
        Text("컨텐츠 영역")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
