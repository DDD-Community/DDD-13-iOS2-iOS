//
//  Selected.swift
//  HomeFeature
//

import SwiftUI
import DesignSystem

/// 특정 장소 핀 선택시 보여줄 디테일 시트
struct SelectedPlaceDetailSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SelectedPlaceDetailHeaderView()
                .padding(.bottom, Spacing.spacing350)
            SelectedPlaceBusinessHoursView()
                .padding(.bottom, Spacing.spacing350)
            SelectedPlaceAddressView()
                .padding(.bottom, Spacing.spacing500)
            SelectedPlaceNaverMapButton()
        }
        .padding(.horizontal, Spacing.spacing400)
    }
}

private struct SelectedPlaceDetailHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("서촌김씨")
                    .pretendardCustomFont(textStyle: .titleLarge)
                    .foregroundStyle(Color.gray800)

                Spacer()

                Image.Asset.icClose24
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Colors.gray500)
            }
            .padding(.bottom, 4)

            HStack(spacing: Spacing.spacing150) {
                Text("18km")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray600)

                SelectedPlaceMetadataDivider()

                Text("디저트")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .padding(.top, Spacing.spacing100)
        }
    }
}

private struct SelectedPlaceBusinessHoursView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            Text("영업 시간")
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(Color.gray900)
            Group {
                Text("월 휴무")
                    
                Text("평일 08:00 - 22:00 / 주말 11:11 - 22:22")
            }
            .pretendardCustomFont(textStyle: .bodySmall)
            .foregroundStyle(Color.gray700)
           
        }
    }
}

private struct SelectedPlaceAddressView: View {
    private let roadAddress = "서울 강남구 테헤란로 123"
    private let lotAddress = "서울 강남구 역삼동 123-45"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            Text("주소")
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(Color.gray900)

            VStack(alignment: .leading, spacing: Spacing.spacing200) {
                PlaceAddressRow(title: "도로명", address: roadAddress)
                PlaceAddressRow(title: "지번", address: lotAddress)
            }
        }
    }
}

private struct SelectedPlaceNaverMapButton: View {
    var body: some View {
        Button {
        } label: {
            Text("네이버 지도로 보기")
                .pretendardCustomFont(textStyle: .labelLarge)
                .foregroundStyle(Colors.gray00)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                        .fill(Colors.gray800)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct SelectedPlaceMetadataDivider: View {
    var body: some View {
        Circle()
            .fill(Colors.gray300)
            .frame(width: 2, height: 2)
    }
}

#Preview {
    SelectedPlaceDetailSheet()
        .padding(.vertical, Spacing.spacing300)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Colors.gray00)
}
