//
//  LocationVoteArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - 케이스 3: 장소 투표 (completed / voting)

struct LocationVoteArea: View {
    let store: StoreOf<GroupDetailFeature>

    // 투표/다시투표 토글은 로컬 인터랙션. 서버의 isMyVote 결과로 초기 동기화한다.
    @State private var hasVoted = false
    @State private var selectedIndex: Int?

    private var candidates: [PlaceVoteCandidate] {
        store.placeVote?.candidates ?? []
    }

    private var maxVoteCount: Int { candidates.map(\.voteCount).max() ?? 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LocationVoteTopArea(
                hasVoted: hasVoted,
                deadlineLabel: PlaceVoteFormatter.deadlineLabel(store.placeVote?.deadline),
                totalParticipants: store.placeVote?.totalParticipants ?? 0,
                votedCount: store.placeVote?.votedCount ?? 0
            )

            LocationVoteList(
                candidates: candidates,
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
        .onChange(of: store.placeVote, initial: true) { _, newValue in
            syncVoteState(from: newValue)
        }
    }

    /// 서버가 내려준 `isMyVote`로 투표 완료 여부와 선택 상태를 초기화한다.
    private func syncVoteState(from placeVote: PlaceVote?) {
        guard let placeVote else { return }

        let votedIndex = placeVote.candidates.firstIndex(where: { $0.isMyVote })
        hasVoted = votedIndex != nil
        selectedIndex = votedIndex
    }
}

// MARK: - Location Vote Top Area

private struct LocationVoteTopArea: View {
    let hasVoted: Bool
    let deadlineLabel: String
    let totalParticipants: Int
    let votedCount: Int

    private var descriptionText: String {
        hasVoted
            ? "모임원 \(totalParticipants)명 / 참여 \(votedCount)명"
            : deadlineLabel
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
    let candidates: [PlaceVoteCandidate]
    let hasVoted: Bool
    let selectedIndex: Int?
    let maxVoteCount: Int
    let onSelect: (Int) -> Void
    let onDetail: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(candidates.enumerated()), id: \.element.id) { index, candidate in
                LocationVoteRow(
                    candidate: candidate,
                    hasVoted: hasVoted,
                    isSelected: selectedIndex == index,
                    isFirstPlace: maxVoteCount > 0 && candidate.voteCount == maxVoteCount,
                    onSelect: { onSelect(index) },
                    onDetail: onDetail
                )
            }
        }
    }
}

// MARK: - Location Vote Row

private struct LocationVoteRow: View {
    let candidate: PlaceVoteCandidate
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

                    LocationVotePlaceInfo(candidate: candidate)
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
            LocationVotePlaceInfo(candidate: candidate)

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
            ? "1위 / \(candidate.voteCount)명 투표"
            : "\(candidate.voteCount)명 투표"
    }
}

// MARK: - Location Vote Place Info

private struct LocationVotePlaceInfo: View {
    let candidate: PlaceVoteCandidate

    var body: some View {
        HStack(spacing: Spacing.spacing250) {
            // TODO: 장소 상세(이름/주소/카테고리) API 연동 시 placeId 노출·임시 아이콘 교체
            Constant.placeholderIcon
                .resizable()
                .frame(width: Sizing.sizing300, height: Sizing.sizing300)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText("\(candidate.placeId)", textStyle: .bodyMediumEmphasized)
                    .foregroundStyle(Colors.gray800)

                BangawoText("\(candidate.placeId)", textStyle: .bodySmall)
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

// MARK: - Place Vote Formatter

private enum PlaceVoteFormatter {
    static func deadlineLabel(_ raw: String?) -> String {
        guard
            let raw,
            let date = DateFormatterStore.date(
                from: raw,
                format: "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",
                locale: "en_US_POSIX",
                timeZone: "UTC"
            )
        else { return "" }

        return "\(DateFormatterStore.string(from: date, format: "yyyy. MM. dd HH:mm"))까지 투표할 수 있어요"
    }
}

// MARK: - Constants

private enum Constant {
    // TODO: 장소 카테고리 API 연동 시 카테고리별 아이콘으로 교체
    static let placeholderIcon = Image.Asset.icMapPinRestaurant
}
