//
//  FAB.swift
//  DesignSystem
//

import SwiftUI

/// Floating Action Button.
///
/// `isPressed` 바인딩으로 enabled / pressed 두 상태를 토글합니다.
/// - enabled: gray800 원 + white(`gray00`) 아이콘
/// - pressed: white(`gray00`) 원 + gray800 아이콘(시계방향 45° 회전) + `Menu` 노출
public struct FAB: View {
    // MARK: - Properties

    @Binding private var isPressed: Bool
    private let menuGroupTitle: String?
    private let menuItems: [Menu.Item]

    // MARK: - Init

    /// - Parameters:
    ///   - isPressed: enabled(`false`) / pressed(`true`) 상태 바인딩.
    ///   - menuGroupTitle: pressed 상태에서 노출되는 `Menu`의 그룹 타이틀.
    ///   - menuItems: pressed 상태에서 노출되는 `Menu`의 항목 목록. 비어 있으면 `Menu`를 표시하지 않습니다.
    public init(
        isPressed: Binding<Bool>,
        menuGroupTitle: String? = nil,
        menuItems: [Menu.Item] = []
    ) {
        self._isPressed = isPressed
        self.menuGroupTitle = menuGroupTitle
        self.menuItems = menuItems
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .trailing, spacing: Metric.menuSpacing) {
            if isPressed, !menuItems.isEmpty {
                Menu(groupTitle: menuGroupTitle, items: menuItems)
            }

            ToggleButton(isPressed: $isPressed)
        }
    }
}

// MARK: - ToggleButton

private extension FAB {
    struct ToggleButton: View {
        @Binding var isPressed: Bool

        var body: some View {
            Button {
                withAnimation(.easeInOut(duration: Metric.toggleAnimationDuration)) {
                    isPressed.toggle()
                }
            } label: {
                Circle()
                    .fill(circleColor)
                    .frame(width: Sizing.sizing600, height: Sizing.sizing600)
                    .overlay {
                        Image.Asset.icFab24
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(iconColor)
                            .rotationEffect(.degrees(isPressed ? Metric.pressedRotation : 0))
                            .padding(Spacing.spacing300)
                    }
                    .shadow(
                        color: BoxShadow.boxShadow400.color,
                        radius: BoxShadow.boxShadow400.blur,
                        x: BoxShadow.boxShadow400.offsetX,
                        y: BoxShadow.boxShadow400.offsetY
                    )
            }
            .buttonStyle(.plain)
        }

        private var circleColor: Color {
            isPressed ? Colors.gray00 : Colors.gray800
        }

        private var iconColor: Color {
            isPressed ? Colors.gray800 : Colors.gray00
        }
    }
}

// MARK: - Metric

private extension FAB {
    enum Metric {
        static let menuSpacing: CGFloat = Spacing.spacing200
        static let pressedRotation: Double = 45
        static let toggleAnimationDuration: Double = 0.2
    }
}

// MARK: - Preview

#Preview("FAB") {
    @Previewable @State var isPressed = false

    ZStack(alignment: .bottomTrailing) {
        Colors.gray200
            .ignoresSafeArea()

        FAB(
            isPressed: $isPressed,
            menuItems: [
                .init(label: "모임 만들기", icon: .Asset.icPlus24) {},
                .init(label: "모임 참여하기", icon: .Asset.icUsersPlus24) {},
            ]
        )
        .padding(.trailing, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing400)
    }
}
