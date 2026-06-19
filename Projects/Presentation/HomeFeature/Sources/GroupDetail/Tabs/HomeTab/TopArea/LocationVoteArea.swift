//
//  LocationVoteArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - 케이스 3: 장소 투표 (completed / voting)

struct LocationVoteArea: View {
    let store: StoreOf<GroupDetailFeature>

    // TODO: 투표 모델 연동 시 로컬 상태 제거 후 store 데이터로 교체
    @State private var hasVoted = false
    @State private var selectedIndex: Int?

    private var places: [TempPlace] { Constant.tempPlaces }

    private var maxVoteCount: Int { places.map(\.voteCount).max() ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LocationVoteTopArea(hasVoted: hasVoted)

            LocationVoteList(
                places: places,
                hasVoted: hasVoted,
                selectedIndex: selectedIndex,
                maxVoteCount: maxVoteCount,
                onSelect: { selectedIndex = $0 },
                onDetail: { store.send(.placeDetailTapped) }
            )

            LocationVoteConfirmArea(
                hasVoted: hasVoted,
                canVote: selectedIndex != nil,
                onVote: {
                    hasVoted = true
                    store.send(.voteForLocationTapped)
                },
                onRevote: { hasVoted = false }
            )
        }
        .padding(.vertical, Spacing.spacing300)
        .padding(.horizontal, Spacing.spacing350)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                .fill(Colors.white)
        )
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
    }
}

// MARK: - Location Vote Top Area

private struct LocationVoteTopArea: View {
    let hasVoted: Bool

    private var descriptionText: String {
        // TODO: 투표 deadline / 참여 현황 모델 연동 시 임시값 교체
        hasVoted ? Constant.tempPlaceVoteParticipationLabel : Constant.tempPlaceVoteRemainingLabel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText("장소 투표하기", textStyle: .titleMediumEmphasized)
                .foregroundStyle(Colors.gray900)

            BangawoText(descriptionText, textStyle: .bodyXSmall)
                .foregroundStyle(Colors.gray600)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.spacing200)
        .padding(.bottom, Spacing.spacing300)
    }
}

// MARK: - Location Vote List

private struct LocationVoteList: View {
    let places: [TempPlace]
    let hasVoted: Bool
    let selectedIndex: Int?
    let maxVoteCount: Int
    let onSelect: (Int) -> Void
    let onDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(places.enumerated()), id: \.offset) { index, place in
                LocationVoteRow(
                    place: place,
                    hasVoted: hasVoted,
                    isSelected: selectedIndex == index,
                    isFirstPlace: maxVoteCount > 0 && place.voteCount == maxVoteCount,
                    onSelect: { onSelect(index) },
                    onDetail: onDetail
                )
            }
        }
    }
}

// MARK: - Location Vote Row

private struct LocationVoteRow: View {
    let place: TempPlace
    let hasVoted: Bool
    let isSelected: Bool
    let isFirstPlace: Bool
    let onSelect: () -> Void
    let onDetail: () -> Void

    var body: some View {
        if hasVoted {
            votedRow
        } else {
            unvotedRow
        }
    }

    private var unvotedRow: some View {
        HStack(spacing: Spacing.spacing250) {
            Button(action: onSelect) {
                HStack(spacing: Spacing.spacing250) {
                    (isSelected ? Image.Asset.icRadioButtonSelected : Image.Asset.icRadioButtonUnselected)
                        .resizable()
                        .frame(width: Sizing.sizing200, height: Sizing.sizing200)

                    LocationVotePlaceInfo(place: place)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            BangawoButton("자세히", variant: .weak, size: .xsmall, action: onDetail)
        }
        .padding(.vertical, Spacing.spacing300)
    }

    private var votedRow: some View {
        HStack(spacing: Spacing.spacing250) {
            LocationVotePlaceInfo(place: place)

            BangawoText(voteStatusText, textStyle: .labelSmallEmphasized)
                .foregroundStyle(isFirstPlace ? Colors.blue600 : Colors.gray700)
        }
        .padding(.vertical, Spacing.spacing300)
        .padding(.horizontal, Spacing.spacing250)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                .fill(isFirstPlace ? Colors.blue100 : .clear)
        )
    }

    private var voteStatusText: String {
        isFirstPlace
            ? "1위 / \(place.voteCount)명 투표"
            : "\(place.voteCount)명 투표"
    }
}

// MARK: - Location Vote Place Info

private struct LocationVotePlaceInfo: View {
    let place: TempPlace

    var body: some View {
        HStack(spacing: Spacing.spacing250) {
            place.categoryIcon
                .resizable()
                .frame(width: Sizing.sizing300, height: Sizing.sizing300)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(place.name, textStyle: .bodyMediumEmphasized)
                    .foregroundStyle(Colors.gray800)

                BangawoText(place.address, textStyle: .bodySmall)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Location Vote Confirm Area

private struct LocationVoteConfirmArea: View {
    let hasVoted: Bool
    let canVote: Bool
    let onVote: () -> Void
    let onRevote: () -> Void

    var body: some View {
        Group {
            if hasVoted {
                BangawoButton("다시 투표하기", variant: .weak, size: .medium, widthType: .maxWidth, action: onRevote)
            } else {
                BangawoButton(
                    "투표하기",
                    variant: .solid,
                    size: .medium,
                    widthType: .maxWidth,
                    isDisabled: !canVote,
                    action: onVote
                )
            }
        }
        .padding(.top, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing200)
    }
}

// MARK: - Temp Models

// TODO: 장소 리스트 모델 구현 시 Entity 로 교체
private struct TempPlace: Identifiable {
    let id = UUID()
    let categoryIcon: Image
    let name: String
    let address: String
    let voteCount: Int
}

// MARK: - Constants

private enum Constant {
    static let tempPlaceVoteRemainingLabel = "투표 시작일 기준 +3일 12:34:56 남았어요"
    static let tempPlaceVoteParticipationLabel = "모임원 5명 / 참여 3명"
    static let tempPlaces: [TempPlace] = [
        TempPlace(
            categoryIcon: Image.Asset.icMapPinRestaurant,
            name: "강남역 모임 장소 A",
            address: "서울 강남구 테헤란로 1",
            voteCount: 3
        ),
        TempPlace(
            categoryIcon: Image.Asset.icMapPinCafe,
            name: "강남역 모임 장소 B",
            address: "서울 강남구 테헤란로 2",
            voteCount: 2
        ),
        TempPlace(
            categoryIcon: Image.Asset.icMapPinDessert,
            name: "강남역 모임 장소 C",
            address: "서울 강남구 테헤란로 3",
            voteCount: 1
        )
    ]
}
