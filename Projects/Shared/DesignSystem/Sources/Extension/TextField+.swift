//
//  TextField+.swift
//  DesignSystem
//
//

import SwiftUI

extension TextField {
    /// TextField 에서 최대 글자수를 정하기 위한 Modifier
    func maxLength(text: Binding<String>, _ maxLength: Int?) -> some View {
        return ModifiedContent(content: self,
                               modifier: MaxLengthModifier(text: text,
                                                           maxLength: maxLength))
    }
}
