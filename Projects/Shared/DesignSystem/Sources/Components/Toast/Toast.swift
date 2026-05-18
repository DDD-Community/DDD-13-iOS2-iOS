//
//  Toast.swift
//  DesignSystem
//

import SwiftUI

public struct Toast: View {
    // MARK: - Properties

    private let message: String

    // MARK: - Init

    public init(_ message: String) {
        self.message = message
    }

    // MARK: - Body

    public var body: some View {
        Text(message)
            .pretendardCustomFont(textStyle: .bodyMediumEmphasized)
            .foregroundStyle(Colors.gray800)
            .padding(.vertical, Spacing.spacing50)
            .padding(.vertical, Spacing.spacing250)
            .padding(.horizontal, Spacing.spacing350)
            .background(Capsule().fill(Colors.gray100))
    }
}

#Preview {
    VStack(spacing: 24) {
        Toast("토스트 메시지입니다")
        Toast("짧은 메시지")
        Toast("조금 더 긴 토스트 메시지가 표시됩니다")
    }
    .padding(24)
}
