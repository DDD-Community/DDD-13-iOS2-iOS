//
//  Checkbox.swift
//  DesignSystem
//

import SwiftUI

public struct Checkbox: View {
    // MARK: - Properties

    private let variant: Variant
    private let state: State
    private let size: Size

    // MARK: - Init

    public init(
        variant: Variant,
        state: State,
        size: Size
    ) {
        self.variant = variant
        self.state = state
        self.size = size
    }

    // MARK: - Body

    public var body: some View {
        checkboxImage
            .resizable()
            .scaledToFit()
            .padding(size.padding)
            .frame(width: size.totalSize, height: size.totalSize)
    }

    // MARK: - Computed

    private var checkboxImage: Image {
        switch (variant, state, size) {
        case (.circle, .enabled, .small): Image.Asset.icCheckboxCircleEnabledSm
        case (.circle, .disabled, .small): Image.Asset.icCheckboxCircleDisabledSm
        case (.circle, .enabled, .medium): Image.Asset.icCheckboxCircleEnabledMd
        case (.circle, .disabled, .medium): Image.Asset.icCheckboxCircleDisabledMd
        case (.ghost, .enabled, .small): Image.Asset.icCheckboxGhostEnabledSm
        case (.ghost, .disabled, .small): Image.Asset.icCheckboxGhostDisabledSm
        case (.ghost, .enabled, .medium): Image.Asset.icCheckboxGhostEnabledMd
        case (.ghost, .disabled, .medium): Image.Asset.icCheckboxGhostDisabledMd
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            Checkbox(variant: .circle, state: .enabled, size: .small)
            Checkbox(variant: .circle, state: .disabled, size: .small)
            Checkbox(variant: .circle, state: .enabled, size: .medium)
            Checkbox(variant: .circle, state: .disabled, size: .medium)
        }

        HStack(spacing: 16) {
            Checkbox(variant: .ghost, state: .enabled, size: .small)
            Checkbox(variant: .ghost, state: .disabled, size: .small)
            Checkbox(variant: .ghost, state: .enabled, size: .medium)
            Checkbox(variant: .ghost, state: .disabled, size: .medium)
        }
    }
    .padding(24)
}
