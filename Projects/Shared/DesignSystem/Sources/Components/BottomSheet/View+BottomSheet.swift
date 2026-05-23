//
//  View+BottomSheet.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    func bangawoBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        header: BottomSheet<Content>.HeaderConfig? = nil,
        contentVerticalPadding: CGFloat = 0,
        buttons: [BottomSheet<Content>.ButtonConfig] = [],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        sheet(isPresented: isPresented) {
            BottomSheet(
                header: header,
                contentVerticalPadding: contentVerticalPadding,
                buttons: buttons,
                content: content
            )
            .presentationDetents([.height(422), .fraction(0.9)])
            .presentationBackground(.clear)
        }
    }
}
