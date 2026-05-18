//
//  NavigationIconItem.swift
//  DesignSystem
//

import SwiftUI

public struct NavigationIconItem: Identifiable {
    public let id: UUID
    public let image: Image
    public let action: () -> Void

    public init(image: Image, action: @escaping () -> Void) {
        self.id = UUID()
        self.image = image
        self.action = action
    }
}
