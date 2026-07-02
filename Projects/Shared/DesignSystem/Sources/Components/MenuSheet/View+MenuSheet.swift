//
//  View+MenuSheet.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    func menuSheet(
        isPresented: Binding<Bool>,
        title: String,
        items: [MenuSheet.Item]
    ) -> some View {
        bottomSheet(isPresented: isPresented) {
            MenuSheet(title: title, items: items) {
                isPresented.wrappedValue = false
            }
        }
    }
}
