//
//  TextInput+MaxLengthModifier.swift
//  DesignSystem
//
//

import SwiftUI

struct MaxCountModifier: ViewModifier {
    @Binding var text: String
    let maxCount: Int?

    func body(content: Content) -> some View {
        content
            .onChange(of: text) { _, newValue in
                guard let maxCount else { return }

                if newValue.count > maxCount {
                    text = String(newValue.prefix(maxCount))
                }
            }
    }
}
