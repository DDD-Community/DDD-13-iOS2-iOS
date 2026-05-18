//
//  Menu+Item.swift
//  DesignSystem
//

import SwiftUI

public extension Menu {
    struct Item {
        let leadingIcon: Image?
        let label: String
        let action: () -> Void

        public init(
            leadingIcon: Image? = nil,
            label: String,
            action: @escaping () -> Void
        ) {
            self.leadingIcon = leadingIcon
            self.label = label
            self.action = action
        }
    }
}
