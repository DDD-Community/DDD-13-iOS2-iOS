//
//  MeetingDateSelectionField.swift
//  HomeFeature
//

import SwiftUI

import DesignSystem

struct MeetingDateSelectionField: View {
    let title: String
    let placeholder: String
    let iconName: String
    let text: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            BangawoText(title, textStyle: .titleSmallEmphasized)
                .foregroundStyle(Colors.gray900)
                .padding(.vertical, Spacing.spacing50)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: action) {
                HStack(spacing: Spacing.spacing200) {
                    if let icon = Image.assetIfExists(named: iconName) {
                        icon
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: Sizing.sizing200, height: Sizing.sizing200)
                            .foregroundStyle(Colors.gray700)
                    }

                    BangawoText(text.isEmpty ? placeholder : text, textStyle: .bodyLarge)
                        .foregroundStyle(text.isEmpty ? Colors.gray500 : Colors.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.all, Spacing.spacing250)
                .background(.clear)
                .overlay {
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                        .stroke(Colors.gray200, lineWidth: BorderWidth.borderWidth150)
                }
            }
            .buttonStyle(.plain)
        }
    }
}
