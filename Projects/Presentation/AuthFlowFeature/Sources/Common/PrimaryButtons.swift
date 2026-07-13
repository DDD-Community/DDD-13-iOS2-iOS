//
//  PrimaryButtons.swift
//  AuthFlowFeature
//
//  AuthFlow 화면 공용 버튼 컴포넌트
//

import SwiftUI

struct PrimaryOutlinedButton: View {
    private let title: String
    private let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}
