//
//  ToggleButton.swift
//  DesignSystem
//

import SwiftUI

public struct ToggleButton: View {
    // MARK: - Properties

    private let isSelected: Bool
    private let action: () -> Void

    // MARK: - Init

    public init(isSelected: Bool, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Image.Asset.icPlus16
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: Sizing.sizing100, height: Sizing.sizing100)
                .foregroundStyle(isSelected ? Colors.white : Colors.gray600)
                .padding(Spacing.spacing200)
                .background {
                    Circle()
                        .fill(isSelected ? Colors.gray800 : Color.clear)
                        .overlay {
                            if !isSelected {
                                Circle()
                                    .stroke(Colors.gray300, lineWidth: BorderWidth.borderWidth100)
                            }
                        }
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("ToggleButton") {
    ZStack {
        Colors.gray200
            .ignoresSafeArea()

        HStack(spacing: Spacing.spacing300) {
            ToggleButton(isSelected: false) {}
            ToggleButton(isSelected: true) {}
        }
    }
}
