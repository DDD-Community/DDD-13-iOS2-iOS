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

    // TODO: 투표 모델 연동 시 로컬 상태 제거 후 store 데이터로 교체
    @State private var hasVoted = false
    @State private var selectedIndices: Set<Int> = []

    private var candidates: [DateVoteCandidate] { Constant.tempCandidates }

    private var isAllSelected: Bool {
        !candidates.isEmpty && selectedIndices.count == candidates.count
    }

    private var isHostAndMe: Bool {
        store.groupDetail?.members.first(where: { $0.isMe })?.isHost ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DateVoteTopArea()

            DateVoteSelectAllButton(isAllSelected: isAllSelected, onSelectAll: toggleSelectAll)

            DateVoteList(
                candidates: candidates,
                hasVoted: hasVoted,
                selectedIndices: selectedIndices,
                onSelect: toggleSelection
            )

            DateVoteConfirmArea(
                hasVoted: hasVoted,
                canVote: !selectedIndices.isEmpty,
                isHostAndMe: isHostAndMe,
                onVote: { hasVoted = true },
                onRevote: { hasVoted = false },
                onConfirm: { store.send(.dateVoteTapped) }
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

    // MARK: Actions

    private func toggleSelection(at index: Int) {
        guard !hasVoted else { return }

        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
    }

    private func toggleSelectAll() {
        guard !hasVoted else { return }

        let allIndices = Set(candidates.indices)
        selectedIndices = selectedIndices == allIndices ? [] : allIndices
    }
}

// MARK: - Date Vote Top Area

private struct DateVoteTopArea: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText("날짜 투표하기", textStyle: .titleMediumEmphasized)
                .foregroundStyle(Colors.gray900)

            // TODO: deadline 모델 연동 시 임시값 교체
            BangawoText(Constant.tempRemainingLabel, textStyle: .bodyXSmall)
                .foregroundStyle(Colors.gray600)

            HStack(spacing: Spacing.spacing100) {
                DateVoteProgressBar(ratio: Constant.tempParticipationRatio)

                BangawoText("\(Constant.tempParticipantCount)명 참여", textStyle: .bodyXSmall)
                    .foregroundStyle(Colors.gray600)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.spacing200)
        .padding(.bottom, Spacing.spacing300)
    }
}

// MARK: - Date Vote Select All Button

private struct DateVoteSelectAllButton: View {
    let isAllSelected: Bool
    let onSelectAll: () -> Void

    var body: some View {
        Button(action: onSelectAll) {
            HStack(spacing: Spacing.spacing100) {
                (isAllSelected ? Image.Asset.icCheckboxGhostEnabledMd : Image.Asset.icCheckboxGhostDisabledMd)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Metric.checkIconLength, height: Metric.checkIconLength)
                    .foregroundStyle(Color(hex: Constant.mutedIconHex))

                Text("전체 선택")
                    .pretendardFont(family: .Medium, size: Metric.voteLabelFontSize)
                    .foregroundStyle(Color(hex: Constant.mutedIconHex))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Spacing.spacing100)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Date Vote List

private struct DateVoteList: View {
    let candidates: [DateVoteCandidate]
    let hasVoted: Bool
    let selectedIndices: Set<Int>
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(candidates.enumerated()), id: \.element.id) { index, candidate in
                DateVoteRow(
                    candidate: candidate,
                    hasVoted: hasVoted,
                    isSelected: selectedIndices.contains(index),
                    onSelect: { onSelect(index) }
                )
            }
        }
    }
}

// MARK: - Date Vote Confirm Area

private struct DateVoteConfirmArea: View {
    let hasVoted: Bool
    let canVote: Bool
    let isHostAndMe: Bool
    let onVote: () -> Void
    let onRevote: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        Group {
            if hasVoted {
                if isHostAndMe {
                    HStack(spacing: Spacing.spacing200) {
                        BangawoButton("다시 투표하기", variant: .weak, size: .medium, widthType: .maxWidth, action: onRevote)

                        BangawoButton("확정하기", variant: .solid, size: .medium, widthType: .maxWidth, action: onConfirm)
                    }
                } else {
                    BangawoButton("다시 투표하기", variant: .weak, size: .medium, widthType: .maxWidth, action: onRevote)
                }
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

// MARK: - Date Vote Progress Bar

private struct DateVoteProgressBar: View {
    let ratio: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Color(hex: Constant.progressTrackHex)
                
                Colors.red500
                    .frame(width: proxy.size.width * max(0, min(ratio, 1)))
            }
        }
        .frame(height: Metric.progressBarHeight)
        .clipShape(Capsule())
    }
}

// MARK: - Date Vote Row

private struct DateVoteRow: View {
    let candidate: DateVoteCandidate
    let hasVoted: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        if hasVoted {
            rowContent
        } else {
            Button(action: onSelect) {
                rowContent
            }
            .buttonStyle(.plain)
        }
    }

    private var rowContent: some View {
        HStack(spacing: Spacing.spacing250) {
            DateVoteRowIndicator(hasVoted: hasVoted, isSelected: isSelected)

            BangawoText(candidate.dateLabel, textStyle: .bodyMediumEmphasized)
                .foregroundStyle(Colors.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasVoted {
                Text("\(candidate.voteCount)명 투표")
                    .pretendardFont(family: .Medium, size: Metric.voteLabelFontSize)
                    .foregroundStyle(isSelected ? Colors.red500 : Colors.gray800)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.spacing300)
        .contentShape(Rectangle())
    }
}

// MARK: - Date Vote Row Indicator

private struct DateVoteRowIndicator: View {
    let hasVoted: Bool
    let isSelected: Bool

    var body: some View {
        if hasVoted {
            if isSelected {
                Image.Asset.icCheckboxGhostEnabledMd
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: Metric.checkIconLength, height: Metric.checkIconLength)
                    .foregroundStyle(Colors.gray800)
            } else {
                Color.clear
                    .frame(width: Metric.checkIconLength, height: Metric.checkIconLength)
            }
        } else {
            Checkbox(variant: .circle, state: isSelected ? .enabled : .disabled, size: .small)
        }
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
    let categoryIcon: Image
    let name: String
    let address: String
    let voteCount: Int
}

// TODO: 날짜 투표 모델 구현 시 Entity 로 교체
private struct DateVoteCandidate: Identifiable {
    let id = UUID()
    let dateLabel: String
    let voteCount: Int
}

// MARK: - Constants

private enum Metric {
    static let categoryIconLength: CGFloat = 40
    static let addressArrowLength: CGFloat = 16
    static let cardGradientRadius: CGFloat = 300
    static let progressBarHeight: CGFloat = 15
    static let checkIconLength: CGFloat = 18
    static let voteLabelFontSize: CGFloat = 12
}

private enum Constant {
    static let mutedIconHex = "#888692"
    static let progressTrackHex = "#E2E1E5"
    // TODO: 날짜 투표 모델 연동 시 임시값 교체
    static let tempRemainingLabel = "투표 시작일 기준 +3일 12:34:56 남았어요"
    static let tempParticipantCount = 3
    static let tempParticipationRatio = 0.6
    static let tempCandidates: [DateVoteCandidate] = [
        DateVoteCandidate(dateLabel: "2026. 06. 17 (수)", voteCount: 2),
        DateVoteCandidate(dateLabel: "2026. 06. 18 (목)", voteCount: 1),
        DateVoteCandidate(dateLabel: "2026. 06. 19 (금)", voteCount: 3)
    ]
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
