//
//  MenuSheet+Item.swift
//  DesignSystem
//

import SwiftUI

public extension MenuSheet {
    struct Item {
        let label: String
        let icon: Image
        let tone: Tone
        let action: () -> Void

        public init(
            label: String,
            icon: Image,
            tone: Tone = .neutral,
            action: @escaping () -> Void
        ) {
            self.label = label
            self.icon = icon
            self.tone = tone
            self.action = action
        }
    }

    enum Tone {
        case neutral
        case critical

        var iconColor: Color {
            switch self {
            case .neutral: return Colors.gray600
            case .critical: return Colors.red600
            }
        }

        var labelColor: Color {
            switch self {
            case .neutral: return Colors.gray800
            case .critical: return Colors.red600
            }
        }
    }
}
