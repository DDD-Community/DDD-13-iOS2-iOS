//
//  MyDeparturePlaceEditSheetContent.swift
//  HomeFeature
//

import ComposableArchitecture
import DesignSystem
import Entity
import SwiftUI
import Utill

struct MyDeparturePlaceEditSheetContent: View {
    let store: StoreOf<HomeTabFeature>

    var body: some View {
        VStack(spacing: Spacing.spacing400) {
            VStack(spacing: Spacing.spacing200) {
                ForEach(departurePlaces) { departurePlace in
                    DeparturePlaceRow(
                        placeName: departurePlace.placeName,
                        roadAddress: departurePlace.roadAddress,
                        onEditTap: {
                            Log.debug("출발지 수정 버튼 클릭: \(departurePlace.id)")
                            store.send(.editDeparturePlaceTapped(id: departurePlace.id))
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AddDeparturePlaceButton(onTap: {
                store.send(.addDeparturePlaceTapped)
            })
        }
        .padding(.horizontal, Metric.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum Metric {
        static let horizontalPadding: CGFloat = -Spacing.spacing250
    }

    private var departurePlaces: [DeparturePlace] {
        store.groupDetail?.members.first(where: \.isMe)?.departurePlaces ?? []
    }
}

// MARK: - DeparturePlaceRow

private struct DeparturePlaceRow: View {
    let placeName: String
    let roadAddress: String
    let onEditTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing250) {
            Image.Asset.icLocation24
                .resizable()
                .renderingMode(.template)
                .frame(width: Metric.iconLength, height: Metric.iconLength)
                .foregroundStyle(Colors.gray600)

            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(placeName, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                BangawoText(roadAddress, textStyle: .bodySmall)
                    .foregroundStyle(Colors.gray700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: onEditTap) {
                BangawoText("수정", textStyle: .labelSmall)
                    .foregroundStyle(Colors.gray800)
                    .padding(.horizontal, Spacing.spacing200)
                    .padding(.vertical, Spacing.spacing100)
                    .background(
                        RoundedRectangle(cornerRadius: BorderRadius.borderRadius225)
                            .fill(Colors.grayAlpha200)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(Metric.contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .fill(Colors.grayAlpha100)
        )
    }

    private enum Metric {
        static let iconLength: CGFloat = 24
        static let contentPadding: CGFloat = 16
    }
}

// MARK: - AddDeparturePlaceButton

private struct AddDeparturePlaceButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing250) {
                Image.Asset.icPlus24
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: Metric.iconLength, height: Metric.iconLength)
                    .foregroundStyle(Colors.gray700)

                BangawoText("출발지 추가하기", textStyle: .bodyLargeEmphasized)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all, Metric.allPadding)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .stroke(Colors.gray300, lineWidth: BorderWidth.borderWidth100)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
            )
        }
        .buttonStyle(.plain)
    }

    private enum Metric {
        static let iconLength: CGFloat = 24
        static let allPadding: CGFloat = 16
    }
}
