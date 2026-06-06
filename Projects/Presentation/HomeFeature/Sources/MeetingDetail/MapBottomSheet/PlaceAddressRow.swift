//
//  PlaceAddressRow.swift
//  HomeFeature
//

import SwiftUI
import UIKit
import DesignSystem

struct PlaceAddressRow: View {
    let title: String
    let address: String

    var body: some View {
        HStack(spacing: Spacing.spacing150) {
            AddressTypeBadge(title: title)

            Text(address)
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(Colors.gray700)
                .lineLimit(1)
                .truncationMode(.tail)

            Button {
                UIPasteboard.general.string = address
            } label: {
                HStack(spacing: Spacing.spacing50) {
                    Image(assetName: "ic_copy_16")
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                }
                .foregroundStyle(Colors.gray600)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct AddressTypeBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .pretendardCustomFont(textStyle: .labelXSmall)
            .foregroundStyle(Colors.gray800)
            .padding(.horizontal, Spacing.spacing150)
            .padding(.vertical, Spacing.spacing50)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .fill(Colors.gray00)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .stroke(Colors.gray300, lineWidth: 1)
            )
    }
}

#Preview {
    VStack(alignment: .leading, spacing: Spacing.spacing200) {
        PlaceAddressRow(title: "도로명", address: "서울 강남구 테헤란로 123")
        PlaceAddressRow(title: "지번", address: "서울 강남구 역삼동 123-45")
    }
    .padding(Spacing.spacing400)
    .background(Colors.gray00)
}
