//
//  Menu+Item.swift
//  DesignSystem
//

import SwiftUI

public extension Menu {
    struct Item {
        let label: String
        let icon: Image?
        let action: () -> Void

        public init(
            label: String,
            icon: Image? = nil,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.icon = icon
            self.action = action
        }
    }
}
