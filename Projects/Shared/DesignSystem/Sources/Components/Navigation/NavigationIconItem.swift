//
//  NavigationIconItem.swift
//  DesignSystem
//

import SwiftUI

public enum NavigationIcon {
    case userPlus24
    case user24
    case ball24
    case verticalMenu24
    case arrowBigRight24
    case close24

    var image: Image {
        switch self {
        case .userPlus24: return Image.Asset.icUserPlus24
        case .user24: return Image.Asset.icUser24
        case .ball24: return Image.Asset.icBall24
        case .verticalMenu24: return Image.Asset.icVerticalMenu24
        case .arrowBigRight24: return Image.Asset.icArrowBigRight24
        case .close24: return Image.Asset.icClose24
        }
    }
}

public struct NavigationIconItem: Identifiable {
    public let id: UUID
    public let icon: NavigationIcon
    public let action: () -> Void

    public init(icon: NavigationIcon, action: @escaping () -> Void) {
        self.id = UUID()
        self.icon = icon
        self.action = action
    }
}

struct NavigationIconButton: View {
    let image: Image
    let action: () -> Void

    @GestureState private var isPressed = false

    var body: some View {
        image
            .frame(width: Sizing.sizing200, height: Sizing.sizing200)
            .background {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                    .fill(isPressed ? Colors.grayAlpha200 : .clear)
                    .frame(width: Spacing.spacing450, height: Spacing.spacing450)
            }
            .frame(width: Sizing.sizing450, height: Sizing.sizing450)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
                    .onEnded { _ in
                        action()
                    }
            )
    }
}
