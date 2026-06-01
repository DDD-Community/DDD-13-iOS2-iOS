//
//  TextField+.swift
//  DesignSystem
//
//

import SwiftUI

extension TextField {
    /// TextField 에서 최대 글자수를 정하기 위한 Modifier
    func maxCount(text: Binding<String>, _ maxCount: Int?) -> some View {
        return modifier(MaxCountModifier(text: text, maxCount: maxCount))
    }
}
