//
//  ActionButton+Types.swift
//  DesignSystem
//

extension ActionButton {
    public enum ButtonLayout {
        case single(title: String, action: () -> Void)
        case dual(
            primaryTitle: String,
            primaryAction: () -> Void,
            secondaryTitle: String,
            secondaryAction: () -> Void,
            arrangement: DualArrangement
        )
    }

    public enum DualArrangement {
        case vertical
        case horizontal
    }

    public enum UpperContent {
        case snackBar(message: String, buttonTitle: String, action: () -> Void)
        case toast(message: String)
        case description(String)
    }

    public struct LowerContent {
        let title: String
        let type: TextButton.ButtonType
        let action: () -> Void

        public init(
            _ title: String,
            type: TextButton.ButtonType = .textOnly,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.type = type
            self.action = action
        }
    }
}
