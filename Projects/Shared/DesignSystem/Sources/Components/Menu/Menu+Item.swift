//
//  Menu+Item.swift
//  DesignSystem
//

import SwiftUI

public extension Menu {
    struct Item {
        let label: String
        let icon: Image?
        let iconColor: Color?
        let action: () -> Void

        public init(
            label: String,
            icon: Image? = nil,
            iconColor: Color? = nil,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.icon = icon
            self.iconColor = iconColor
            self.action = action
        }
    }
}
