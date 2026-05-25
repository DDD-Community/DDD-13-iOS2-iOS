//
//  View+BottomSheetOverlay.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    /// `ZStack` 오버레이와 `ViewModifier`로 직접 구현한 BottomSheet modifier입니다.
    /// 드래그 제스처와 snap 로직을 수동으로 관리하며, 두 단계 detent(0.5 / 0.9)를 지원합니다.
    /// - TODO: 스크롤 뷰와 드래그 제스처 충돌, dismiss 시 sheetDetent 초기화 타이밍 등 상호작용 개선 예정
    func customBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        header: BottomSheet<Content>.HeaderConfig? = nil,
        contentVerticalPadding: CGFloat = 0,
        buttons: [BottomSheet<Content>.ButtonConfig] = [],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            BottomSheetOverlayModifier(
                isPresented: isPresented,
                header: header,
                contentVerticalPadding: contentVerticalPadding,
                buttons: buttons,
                content: content
            )
        )
    }
}

// MARK: - BottomSheetOverlayModifier

private struct BottomSheetOverlayModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let header: BottomSheet<SheetContent>.HeaderConfig?
    let contentVerticalPadding: CGFloat
    let buttons: [BottomSheet<SheetContent>.ButtonConfig]
    let content: () -> SheetContent

    @State private var keyboardHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var canExpand = false
    @State private var sheetDetent: SheetDetent = .default

    private enum SheetDetent { case `default`, expanded }

    private var screenHeight: CGFloat { UIScreen.main.bounds.height }
    private var defaultHeight: CGFloat { screenHeight * 0.5 }
    private var maxHeight: CGFloat { screenHeight * 0.9 }

    // detent의 base height에서 dragOffset을 뺀 effective height: [defaultHeight, maxHeight]로 클램핑
    private var sheetHeight: CGFloat {
        let effective = baseHeight - dragOffset
        return max(defaultHeight, min(maxHeight, effective))
    }

    // effective height가 defaultHeight 아래로 내려가는 만큼 슬라이드 오프셋으로 전환
    private var sheetSlideOffset: CGFloat {
        max(0, dragOffset - (baseHeight - defaultHeight))
    }

    private var baseHeight: CGFloat {
        sheetDetent == .expanded ? maxHeight : defaultHeight
    }

    func body(content parentContent: Content) -> some View {
        ZStack {
            parentContent

            if isPresented {
                Colors.grayAlpha700
                    .ignoresSafeArea()
                    .onTapGesture { isPresented = false }
                    .transition(.opacity)

                VStack {
                    Spacer()
                    BottomSheet(
                        header: header,
                        contentVerticalPadding: contentVerticalPadding,
                        buttons: buttons,
                        canExpand: $canExpand,
                        content: content
                    )
                    .frame(height: sheetHeight)
                    .offset(y: sheetSlideOffset)
                    .padding(.bottom, keyboardHeight)
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                let translation = value.translation.height
                                guard canExpand || translation > 0 else { return }
                                dragOffset = translation
                            }
                            .onEnded { value in
                                if value.translation.height > 0 {
                                    handleDownDragEnded()
                                } else if value.translation.height < 0 {
                                    handleUpDragEnded()
                                }
                            }
                    )
                }
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(.keyboard)
        .animation(.spring(duration: 0.35), value: isPresented)
        .onChange(of: isPresented) { _, newValue in
            if !newValue {
                dragOffset = 0
                sheetDetent = .default
                canExpand = false
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
        ) { notification in
            guard
                let userInfo = notification.userInfo,
                let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }
            let screenHeight = UIScreen.main.bounds.height
            let height = max(0, screenHeight - endFrame.minY)
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = height
            }
        }
        .onReceive(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        ) { notification in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            withAnimation(.easeOut(duration: duration)) {
                keyboardHeight = 0
            }
        }
    }

    // sheetHeight 또는 sheetSlideOffset 기준으로 snap / dismiss 결정
    private func handleDownDragEnded() {
        if sheetDetent == .expanded {
            let mid = (defaultHeight + maxHeight) / 2
            if sheetHeight > mid {
                withAnimation(.spring(duration: 0.35)) { dragOffset = 0 }
            } else if sheetSlideOffset > 120 {
                isPresented = false
            } else {
                withAnimation(.spring(duration: 0.35)) {
                    sheetDetent = .default
                    dragOffset = 0
                }
            }
        } else {
            if sheetSlideOffset > 120 {
                isPresented = false
            } else {
                withAnimation(.spring(duration: 0.35)) { dragOffset = 0 }
            }
        }
    }

    // sheetHeight 기준으로 expanded snap 또는 default 복귀 (canExpand일 때만)
    private func handleUpDragEnded() {
        guard canExpand, sheetDetent == .default else {
            withAnimation(.spring(duration: 0.35)) { dragOffset = 0 }
            return
        }
        let mid = (defaultHeight + maxHeight) / 2
        withAnimation(.spring(duration: 0.35)) {
            if sheetHeight > mid { sheetDetent = .expanded }
            dragOffset = 0
        }
    }
}

// MARK: - Preview

#Preview("헤더 + 버튼 1개") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .customBottomSheet(
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
                .customBottomSheet(
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

#Preview("헤더 없음 + 버튼 없음") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .customBottomSheet(
                    isPresented: $isPresented,
                    contentVerticalPadding: Spacing.spacing400
                ) {
                    Text("컨텐츠만 있는 시트")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
        }
    }
    return Preview()
}

#Preview("콘텐츠 오버플로우 (스크롤 + 확장)") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .customBottomSheet(
                    isPresented: $isPresented,
                    header: .init(title: "스크롤 + 확장 테스트", onClose: { isPresented = false }),
                    contentVerticalPadding: Spacing.spacing400,
                    buttons: [.init(title: "확인") { isPresented = false }]
                ) {
                    VStack(spacing: Spacing.spacing200) {
                        ForEach(0..<10, id: \.self) { i in
                            Text("항목 \(i + 1)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
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
                .customBottomSheet(
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
