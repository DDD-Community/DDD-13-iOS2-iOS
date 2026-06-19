//
//  DateVoteTopPage.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - 케이스 1: 날짜 투표 (inProgress / before)

struct DateVoteTopPage: View {
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

// MARK: - Temp Models

// TODO: 날짜 투표 모델 구현 시 Entity 로 교체
private struct DateVoteCandidate: Identifiable {
    let id = UUID()
    let dateLabel: String
    let voteCount: Int
}

// MARK: - Constants

private enum Metric {
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
}
