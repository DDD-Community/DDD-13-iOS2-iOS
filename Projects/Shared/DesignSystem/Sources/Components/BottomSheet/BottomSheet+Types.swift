//
//  BottomSheet+Types.swift
//  DesignSystem
//

public extension BottomSheet {
    struct HeaderConfig {
        public let title: String
        public let description: String?
        public let onClose: (() -> Void)?

        public init(
            title: String,
            description: String? = nil,
            onClose: (() -> Void)? = nil
        ) {
            self.title = title
            self.description = description
            self.onClose = onClose
        }
    }

    struct ButtonConfig {
        public let title: String
        public let action: () -> Void

        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
}
