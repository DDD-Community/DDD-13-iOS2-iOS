//
//  DateVoteTopPage.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - 케이스 1: 날짜 투표 (inProgress / before)

struct DateVoteTopPage: View {
    let store: StoreOf<GroupDetailFeature>

    // 투표/다시투표 토글은 로컬 인터랙션. 서버의 isMyVote 결과로 초기 동기화한다.
    @State private var hasVoted = false
    @State private var selectedIndices: Set<Int> = []

    private var options: [DateVoteOption] {
        store.dateVote?.options ?? []
    }

    private var isAllSelected: Bool {
        !options.isEmpty && selectedIndices.count == options.count
    }

    private var isHostAndMe: Bool {
        store.groupDetail?.members.first(where: { $0.isMe })?.isHost ?? false
    }

    /// 후보 날짜에 표를 던진 고유 참여자 수.
    private var participantCount: Int {
        Set(options.flatMap { $0.voters.map(\.id) }).count
    }

    private var totalMemberCount: Int {
        store.groupDetail?.members.count ?? 0
    }

    private var participationRatio: Double {
        totalMemberCount > 0 ? Double(participantCount) / Double(totalMemberCount) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DateVoteTopArea(
                deadlineLabel: DateVoteFormatter.deadlineLabel(store.dateVote?.deadline),
                participantCount: participantCount,
                participationRatio: participationRatio
            )

            DateVoteSelectAllButton(isAllSelected: isAllSelected, onSelectAll: toggleSelectAll)

            DateVoteList(
                options: options,
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
        .onChange(of: store.dateVote, initial: true) { _, newValue in
            syncVoteState(from: newValue)
        }
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

        let allIndices = Set(options.indices)
        selectedIndices = selectedIndices == allIndices ? [] : allIndices
    }

    /// 서버가 내려준 `isMyVote`로 투표 완료 여부와 선택 상태를 초기화한다.
    private func syncVoteState(from dateVote: DateVote?) {
        guard let dateVote else { return }

        let votedIndices = dateVote.options.enumerated()
            .filter { $0.element.isMyVote }
            .map(\.offset)
        hasVoted = !votedIndices.isEmpty
        selectedIndices = Set(votedIndices)
    }
}

// MARK: - Date Vote Top Area

private struct DateVoteTopArea: View {
    let deadlineLabel: String
    let participantCount: Int
    let participationRatio: Double

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText("날짜 투표하기", textStyle: .titleMediumEmphasized)
                .foregroundStyle(Colors.gray900)

            BangawoText(deadlineLabel, textStyle: .bodyXSmall)
                .foregroundStyle(Colors.gray600)

            HStack(spacing: Spacing.spacing100) {
                DateVoteProgressBar(ratio: participationRatio)

                BangawoText("\(participantCount)명 참여", textStyle: .bodyXSmall)
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
    let options: [DateVoteOption]
    let hasVoted: Bool
    let selectedIndices: Set<Int>
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(options.enumerated()), id: \.element.id) { index, option in
                DateVoteRow(
                    option: option,
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
    let option: DateVoteOption
    let hasVoted: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        if hasVoted {
            DateVoteRowContent(option: option, hasVoted: hasVoted, isSelected: isSelected)
        } else {
            Button(action: onSelect) {
                DateVoteRowContent(option: option, hasVoted: hasVoted, isSelected: isSelected)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Date Vote Row Content

private struct DateVoteRowContent: View {
    let option: DateVoteOption
    let hasVoted: Bool
    let isSelected: Bool

    var body: some View {
        HStack(spacing: Spacing.spacing250) {
            DateVoteRowIndicator(hasVoted: hasVoted, isSelected: isSelected)

            BangawoText(DateVoteFormatter.dateLabel(option.candidateDate), textStyle: .bodyMediumEmphasized)
                .foregroundStyle(Colors.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)

            if hasVoted {
                Text("\(option.voteCount)명 투표")
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
        if !hasVoted {
            Checkbox(variant: .circle, state: isSelected ? .enabled : .disabled, size: .small)
        } else if isSelected {
            Image.Asset.icCheckboxGhostEnabledMd
                .renderingMode(.template)
                .resizable()
                .frame(width: Metric.checkIconLength, height: Metric.checkIconLength)
                .foregroundStyle(Colors.gray800)
        }
    }
}

// MARK: - Date Vote Formatter

private enum DateVoteFormatter {
    static func dateLabel(_ raw: String) -> String {
        guard let date = DateFormatterStore.date(from: raw, format: "yyyy-MM-dd") else { return raw }

        return DateFormatterStore.string(from: date, format: "yyyy. MM. dd (E)")
    }

    static func deadlineLabel(_ raw: String?) -> String {
        guard let raw, let date = DateFormatterStore.date(from: raw, format: "yyyy-MM-dd") else { return "" }

        return "\(DateFormatterStore.string(from: date, format: "yyyy. MM. dd"))까지 투표할 수 있어요"
    }
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
}
