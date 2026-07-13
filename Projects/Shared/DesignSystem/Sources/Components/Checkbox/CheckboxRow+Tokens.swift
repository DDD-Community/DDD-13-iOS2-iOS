//
//  CheckboxRow+Tokens.swift
//  DesignSystem
//

extension CheckboxRow.Size {
    var checkboxSize: Checkbox.Size {
        switch self {
        case .small: return .small
        case .medium: return .medium
        }
    }

    var titleFont: CustomSizeFont {
        switch self {
        case .small: return .titleSmall
        case .medium: return .titleMedium
        }
    }

    var descriptionFont: CustomSizeFont {
        switch self {
        case .small: return .bodyXSmall
        case .medium: return .bodySmall
        }
    }
}
