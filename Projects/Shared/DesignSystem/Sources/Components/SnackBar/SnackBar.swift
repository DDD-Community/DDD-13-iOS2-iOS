//
//  SnackBar.swift
//  DesignSystem
//

import SwiftUI

public struct SnackBar: View {
    // MARK: - Properties

    private let message: String
    private let buttonTitle: String
    private let action: () -> Void

    // MARK: - Init

    public init(
        _ message: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Image.Asset.icCircleQuestionFilled24
                .renderingMode(.template)
                .foregroundStyle(Colors.orange500)

            Text(message)
                .pretendardCustomFont(textStyle: .bodyMediumEmphasized)
                .foregroundStyle(Colors.gray800)
                .padding(.vertical, Spacing.spacing50)
                .frame(maxWidth: .infinity, alignment: .leading)

            BangawoButton(buttonTitle, variant: .weak, size: .xsmall, action: action)
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing350)
        .background(Capsule().fill(Colors.gray100))
    }
}

#Preview {
    VStack(spacing: 24) {
        SnackBar("안내 메시지가 여기에 표시됩니다", buttonTitle: "확인") {}
        SnackBar("짧은 메시지", buttonTitle: "닫기") {}
    }
    .padding(24)
}
