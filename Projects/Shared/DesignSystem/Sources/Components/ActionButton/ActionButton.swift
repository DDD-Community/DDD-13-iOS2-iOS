//
//  ActionButton.swift
//  DesignSystem
//

import SwiftUI

public struct ActionButton: View {
    // MARK: - Properties

    private let buttonLayout: ButtonLayout
    private let upperContent: UpperContent?
    private let isUpperContentVisible: Binding<Bool>?
    private let lowerContent: LowerContent?

    // MARK: - Init

    public init(
        buttonLayout: ButtonLayout,
        upperContent: UpperContent? = nil,
        isUpperContentVisible: Binding<Bool>? = nil,
        lowerContent: LowerContent? = nil
    ) {
        self.buttonLayout = buttonLayout
        self.upperContent = upperContent
        self.isUpperContentVisible = isUpperContentVisible
        self.lowerContent = lowerContent
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            if let upper = upperContent {
                UpperArea(content: upper, isVisible: isUpperContentVisible)
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
        let isVisible: Binding<Bool>?

        @State private var isShowing = false
        @State private var dismissTask: Task<Void, Never>?

        var body: some View {
            Group {
                switch content {
                case let .description(text):
                    BangawoText(text, textStyle: .bodyLarge)
                        .foregroundStyle(Colors.gray700)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, Spacing.spacing400)
                        .padding(.horizontal, Spacing.spacing450)

                case let .snackBar(message, buttonTitle, action):
                    if isShowing {
                        SnackBar(message, buttonTitle: buttonTitle, action: action)
                            .padding(.bottom, Spacing.spacing400)
                            .padding(.horizontal, Spacing.spacing450)
                            .transition(.offset(y: 64).combined(with: .opacity))
                    }

                case let .toast(message):
                    if isShowing {
                        Toast(message)
                            .padding(.bottom, Spacing.spacing400)
                            .padding(.horizontal, Spacing.spacing450)
                            .transition(.offset(y: 64).combined(with: .opacity))
                    }
                }
            }
            .onChange(of: isVisible?.wrappedValue) { _, newValue in
                switch content {
                case .toast, .snackBar:
                    if newValue == true { show() } else { hide() }
                case .description:
                    break
                }
            }
            // 뷰가 사라질 때 자동 닫기 Task를 취소해 좀비 콜백 방지
            .onDisappear {
                dismissTask?.cancel()
            }
        }

        private func show() {
            dismissTask?.cancel()
            withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
                isShowing = true
            }
            dismissTask = Task { @MainActor in
                do { try await Task.sleep(for: .seconds(3)) } catch { return }
                withAnimation(.easeIn(duration: 0.25)) {
                    isShowing = false
                }
                do { try await Task.sleep(for: .seconds(0.25)) } catch { return }
                isVisible?.wrappedValue = false
            }
        }

        private func hide() {
            dismissTask?.cancel()
            withAnimation(.easeIn(duration: 0.25)) {
                isShowing = false
            }
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
            TextButton(content.title, type: content.type, size: .large, action: content.action)
                .padding(.top, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing200)
                .padding(.horizontal, Spacing.spacing450)
        }
    }
}

#Preview("Toast") {
    @Previewable @State var showToast = false

    VStack(spacing: 0) {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("이벤트 발생 버튼을 눌러\nToast 애니메이션을 확인하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("이벤트 발생") { showToast = true }
                    .buttonStyle(.borderedProminent)
                    .disabled(showToast)
            }
        }

        ActionButton(
            buttonLayout: .single(title: "확인", action: {}),
            upperContent: .toast(message: "토스트 메시지입니다"),
            isUpperContentVisible: $showToast
        )
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("SnackBar") {
    @Previewable @State var showSnackBar = false

    VStack(spacing: 0) {
        ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("이벤트 발생 버튼을 눌러\nSnackBar 애니메이션을 확인하세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("이벤트 발생") { showSnackBar = true }
                    .buttonStyle(.borderedProminent)
                    .disabled(showSnackBar)
            }
        }

        ActionButton(
            buttonLayout: .single(title: "확인", action: {}),
            upperContent: .snackBar(message: "안내 메시지입니다", buttonTitle: "닫기", action: { showSnackBar = false }),
            isUpperContentVisible: $showSnackBar,
            lowerContent: .init("더 알아보기", type: .textWithArrow, action: {})
        )
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Description (Static)") {
    VStack(spacing: 0) {
        Spacer()

        ActionButton(
            buttonLayout: .single(title: "확인", action: {}),
            upperContent: .description("안내 문구가 여기에 표시됩니다")
        )
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Dual Vertical") {
    VStack(spacing: 0) {
        Spacer()

        ActionButton(
            buttonLayout: .dual(
                primaryTitle: "확인",
                primaryAction: {},
                secondaryTitle: "취소",
                secondaryAction: {},
                arrangement: .vertical
            ),
            lowerContent: .init("건너뛰기", action: {})
        )
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemBackground))
    }
}

#Preview("Dual Horizontal") {
    VStack(spacing: 0) {
        Spacer()

        ActionButton(buttonLayout: .dual(
            primaryTitle: "확인",
            primaryAction: {},
            secondaryTitle: "취소",
            secondaryAction: {},
            arrangement: .horizontal
        ))
        .padding(.bottom, 16)
        .background(Color(uiColor: .systemBackground))
    }
}
