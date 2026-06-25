//
//  MyDeparturePlaceEditSheetContent.swift
//  HomeFeature
//

import ComposableArchitecture
import DesignSystem
import SwiftUI
import Utill

struct MyDeparturePlaceEditSheetContent: View {
    let store: StoreOf<HomeTabFeature>

    var body: some View {
        VStack(spacing: Spacing.spacing400) {
            VStack(spacing: Spacing.spacing200) {
                ForEach(Constant.departurePlaces) { departurePlace in
                    DeparturePlaceRow(
                        stationName: departurePlace.stationName,
                        address: departurePlace.address,
                        onEditTap: {
                            Log.debug("수정 버튼 클릭")
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AddDeparturePlaceButton(onTap: {
                Log.debug("출발지 추가하기 버튼 클릭")
            })
        }
        .padding(.horizontal, Metric.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum Metric {
        static let horizontalPadding: CGFloat = -Spacing.spacing250
    }
}

// MARK: - DeparturePlaceRow

private struct DeparturePlaceRow: View {
    let stationName: String
    let address: String
    let onEditTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing250) {
            Image.Asset.icLocation24
                .resizable()
                .renderingMode(.template)
                .frame(width: Metric.iconLength, height: Metric.iconLength)
                .foregroundStyle(Colors.gray600)

            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(stationName, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                BangawoText(address, textStyle: .bodySmall)
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

// MARK: - Constant

private enum Constant {
    static let departurePlaces: [DeparturePlaceItem] = [
        .init(
            stationName: "강남역",
            address: "서울 강남구 강남대로 396"
        ),
        .init(
            stationName: "홍대입구역",
            address: "서울 마포구 양화로 188"
        ),
        .init(
            stationName: "성수역",
            address: "서울 성동구 아차산로 100"
        )
    ]

    struct DeparturePlaceItem: Identifiable {
        let stationName: String
        let address: String

        var id: String {
            stationName
        }
    }
}
