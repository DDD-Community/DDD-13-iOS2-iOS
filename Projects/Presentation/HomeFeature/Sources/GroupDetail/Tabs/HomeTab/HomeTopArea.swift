//
//  HomeTopArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - Home Top Area

/// 모임 진행 단계(`dateVoteStatus` × `locationStatus`)에 따라 상단 영역을 분기한다.
struct HomeTopArea: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        switch (store.group.dateVoteStatus, store.group.locationStatus) {
        case (.inProgress, .before):
            DateVoteTopPage(store: store)

        case (.completed, .recommended):
            ConfirmedDateArea(store: store)

        case (.completed, .voting):
            LocationVoteArea(store: store)

        case (.completed, .confirmed):
            ConfirmedPlaceArea(store: store)

        default:
            DefaultTopPage(store: store)
        }
    }
}

// MARK: - Default Top Page (before / before)

private struct DefaultTopPage: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        TopPage(
            d3Asset: .groupDetail,
            title: store.group.name,
            description: store.group.themeTagDisplay,
            buttonTitle: "장소 정하기",
            buttonVariant: .solid,
            buttonSize: .small,
            showLowerArea: false,
            buttonAction: { store.send(.decidePlaceTapped) }
        )
    }
}

// MARK: - 케이스 1: 날짜 투표 (inProgress / before)

private struct DateVoteTopPage: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        TopPage(
            d3Asset: .agreement,
            title: "모임 날짜 투표하기",
            // TODO: deadline 모델 연동 시 임시값 교체
            description: "투표기간: \(Constant.tempVoteRemainingDays)일",
            buttonTitle: "투표하기",
            buttonVariant: .solid,
            buttonSize: .small,
            showLowerArea: false,
            buttonAction: { store.send(.dateVoteTapped) }
        )
    }
}

// MARK: - 케이스 2: 약속 날짜 확정 (completed / recommended)

private struct ConfirmedDateArea: View {
    let store: StoreOf<GroupDetailFeature>

    // TODO: GroupDetail.confirmedDate 모델 연동 시 임시 Date 교체 + 서버 포맷 파싱
    private var confirmedDate: Date { Constant.tempConfirmedDate }

    private var dayNumber: String { DateFormatterStore.day.string(from: confirmedDate) }
    private var weekdayEnglish: String { DateFormatterStore.weekdayEnglish.string(from: confirmedDate).uppercased() }
    private var fullDateLabel: String { DateFormatterStore.full.string(from: confirmedDate) }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText("약속 날짜 확정", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            VStack(alignment: .trailing, spacing: Spacing.spacing200) {
                HStack(spacing: Sizing.sizing75) {
                    VStack(spacing: Spacing.spacing50) {
                        BangawoText(dayNumber, textStyle: .titleMediumEmphasized)
                            .foregroundStyle(Colors.gray900)

                        BangawoText(weekdayEnglish, textStyle: .bodyXSmall)
                            .foregroundStyle(Colors.gray700)
                    }
                    .padding(.vertical, Spacing.spacing150)
                    .padding(.horizontal, Spacing.spacing250)
                    .background(
                        RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                            .fill(Colors.gray200)
                    )

                    VStack(alignment: .leading, spacing: Spacing.spacing50) {
                        BangawoText("약속 날짜", textStyle: .bodySmall)
                            .foregroundStyle(Colors.gray700)

                        BangawoText(fullDateLabel, textStyle: .titleSmall)
                            .foregroundStyle(Colors.gray800)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                BangawoButton("장소고르기", variant: .solid, size: .small) {
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

// MARK: - 케이스 3: 장소 투표 (completed / voting)

private struct LocationVoteArea: View {
    let store: StoreOf<GroupDetailFeature>

    @State private var selectedIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing300) {
            // TODO: 투표 deadline 모델 연동 시 임시값 교체
            Badge(Constant.tempVoteDeadlineLabel, variant: .outline, size: .small)

            VStack(spacing: Spacing.spacing150) {
                // TODO: 장소 리스트 모델 연동 시 임시 데이터 교체
                ForEach(Array(Constant.tempPlaces.enumerated()), id: \.offset) { index, place in
                    LocationVoteRow(
                        place: place,
                        isSelected: selectedIndex == index,
                        onSelect: { selectedIndex = index },
                        onDetail: { store.send(.placeDetailTapped) }
                    )
                }
            }

            BangawoButton("장소 투표하기", variant: .solid, size: .medium, widthType: .maxWidth) {
                store.send(.voteForLocationTapped)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
    }
}

private struct LocationVoteRow: View {
    let place: TempPlace
    let isSelected: Bool
    let onSelect: () -> Void
    let onDetail: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Button(action: onSelect) {
                HStack(spacing: Spacing.spacing200) {
                    (isSelected ? Image.Asset.icRadioButtonSelected : Image.Asset.icRadioButtonUnselected)
                        .resizable()
                        .frame(width: Sizing.sizing200, height: Sizing.sizing200)

                    BangawoText(place.name, textStyle: .bodyLarge)
                        .foregroundStyle(Colors.gray800)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            TextButton("자세히보기", type: .textWithArrow, size: .small, action: onDetail)
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing200)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .fill(isSelected ? Colors.grayAlpha50 : .clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .stroke(
                    isSelected ? Colors.gray800 : Colors.gray200,
                    lineWidth: BorderWidth.borderWidth150
                )
        )
    }
}

// MARK: - 케이스 4: 확정 장소 (completed / confirmed)

private struct ConfirmedPlaceArea: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText("약속 장소 확정", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            VStack(alignment: .trailing, spacing: Spacing.spacing300) {
                HStack(spacing: Sizing.sizing75) {
                    // TODO: 장소 카테고리 모델 연동 시 임시 아이콘 교체
                    Image.Asset.icMapPinRestaurant
                        .resizable()
                        .frame(width: Metric.categoryIconLength, height: Metric.categoryIconLength)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: Spacing.spacing50) {
                        // TODO: 장소명 모델 연동 시 임시값 교체
                        BangawoText(Constant.tempPlaceName, textStyle: .bodyLargeEmphasized)
                            .foregroundStyle(Colors.gray800)

                        HStack(spacing: Spacing.spacing50) {
                            BangawoText(
                                store.group.locationAddress ?? Constant.tempPlaceAddress,
                                textStyle: .bodySmall
                            )
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

// MARK: - Temp Models

// TODO: 장소 리스트 모델 구현 시 Entity 로 교체
private struct TempPlace: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - Constants

private enum Metric {
    static let categoryIconLength: CGFloat = 40
    static let addressArrowLength: CGFloat = 16
    static let cardGradientRadius: CGFloat = 300
}

private enum Constant {
    static let tempVoteRemainingDays = 3
    static let tempConfirmedDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 28
        components.hour = 18
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date()
    }()
    static let tempVoteDeadlineLabel = "투표 마감 D-2"
    static let tempPlaceName = "확정된 장소"
    static let tempPlaceAddress = "주소 정보 없음"
    static let tempPlaces: [TempPlace] = [
        TempPlace(name: "강남역 모임 장소 A"),
        TempPlace(name: "강남역 모임 장소 B"),
        TempPlace(name: "강남역 모임 장소 C")
    ]
}
