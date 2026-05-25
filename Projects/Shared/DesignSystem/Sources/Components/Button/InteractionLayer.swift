//
//  InteractionLayer.swift
//  DesignSystem
//

import SwiftUI

struct InteractionLayer: View {
    enum Interaction {
        case normal
        case strong
    }

    enum InteractionState {
        case hovered
        case focused
        case pressed
    }

    private let interaction: Interaction
    private let state: InteractionState

    init(_ interaction: Interaction, _ state: InteractionState) {
        self.interaction = interaction
        self.state = state
    }

    var body: some View {
        color
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var color: Color {
        switch (interaction, state) {
        case (.normal, .hovered): return Colors.grayAlpha200
        case (.normal, .focused): return Colors.grayAlpha300
        case (.normal, .pressed): return Colors.grayAlpha400
        case (.strong, .hovered): return Colors.grayAlpha100
        case (.strong, .focused): return Colors.grayAlpha200
        case (.strong, .pressed): return Colors.grayAlpha300
        }
    }
}
