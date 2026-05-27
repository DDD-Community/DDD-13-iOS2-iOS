//
//  TextInput+MaxLengthModifier.swift
//  DesignSystem
//
//

import SwiftUI

struct MaxLengthModifier: ViewModifier {
    @Binding var text: String
    let maxLength: Int?

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { _, newValue in
                guard let maxLength else { return }

                if newValue.count > maxLength {
                    text = String(newValue.prefix(maxLength))
                }
            }
    }
}
