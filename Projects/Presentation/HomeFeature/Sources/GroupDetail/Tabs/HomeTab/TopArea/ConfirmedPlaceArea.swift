//
//  ConfirmedPlaceArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - 케이스 4: 확정 장소 (completed / confirmed)

struct ConfirmedPlaceArea: View {
    let store: StoreOf<HomeTabFeature>

    private var placeName: String {
        store.confirmedPlaceResult?.placeName ?? Constant.tempPlaceName
    }

    private var placeAddress: String {
        store.confirmedPlaceResult?.address
            ?? store.group.locationAddress
            ?? Constant.tempPlaceAddress
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText("약속 장소가 확정되었어요", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            VStack(alignment: .trailing, spacing: Spacing.spacing300) {
                HStack(spacing: Sizing.sizing75) {
                    // TODO: 장소 카테고리 모델 연동 시 임시 아이콘 교체
                    Image.Asset.icMapPinRestaurant
                        .resizable()
                        .frame(width: Metric.categoryIconLength, height: Metric.categoryIconLength)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: Spacing.spacing50) {
                        BangawoText(placeName, textStyle: .bodyLargeEmphasized)
                            .foregroundStyle(Colors.gray800)

                        HStack(spacing: Spacing.spacing50) {
                            BangawoText(placeAddress, textStyle: .bodySmall)
                                .foregroundStyle(Colors.gray700)

                            Image.Asset.icArrowSmallDown16
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: Metric.addressArrowLength, height: Metric.addressArrowLength)
                                .foregroundStyle(Colors.gray700)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                BangawoButton("자세히보기", variant: .solid, size: .small) {
                    store.send(.selectPlaceTapped)
                }
            }
            .padding(Spacing.spacing300)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(
                        RadialGradient(
                            colors: [Colors.neutralAlpha700, Colors.neutralAlpha900],
                            center: .center,
                            startRadius: 0,
                            endRadius: Metric.cardGradientRadius
                        )
                    )
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
    }
}

// MARK: - Constants

private enum Metric {
    static let categoryIconLength: CGFloat = 40
    static let addressArrowLength: CGFloat = 16
    static let cardGradientRadius: CGFloat = 300
}

private enum Constant {
    static let tempPlaceName = "확정된 장소"
    static let tempPlaceAddress = "주소 정보 없음"
}
