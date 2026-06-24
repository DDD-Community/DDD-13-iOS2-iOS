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
    let store: StoreOf<HomeTabFeature>

    // 다시 투표하기로 진입한 재선택 모드 등 서버 투표 여부와 무관한 로컬 인터랙션 상태.
    @State private var selection = DateVoteSelection()

    private var options: [DateVoteOption] {
        store.dateVote?.options ?? []
    }

    private var allOptionIds: Set<Int> {
        Set(options.map(\.id))
    }

    // 서버 투표 여부(hasVotedDate)와 로컬 재투표 상태를 조합한 투표 완료 화면 표시 여부.
    private var hasVoted: Bool {
        store.hasVotedDate && !selection.isRevoting
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DateVoteTopArea(
                deadline: store.dateVote?.deadline,
                participantCount: store.dateVoteParticipantCount,
                participationRatio: store.dateVoteParticipationRatio
            )

            DateVoteSelectAllButton(
                isAllSelected: selection.isAllSelected(of: allOptionIds),
                onSelectAll: toggleSelectAll
            )

            DateVoteList(
                options: options,
                hasVoted: hasVoted,
                selectedOptionIds: selection.optionIds,
                onSelect: { selection.toggle($0) }
            )

            DateVoteConfirmArea(
                hasVoted: hasVoted,
                canVote: selection.hasSelection,
                isHostAndMe: store.isMeHost,
                onVote: submitVote,
                onRevote: { selection.startRevote(myVotedIds: store.myVotedDateOptionIds) },
                onConfirm: { store.send(.dateVoteConfirmTapped) }
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

    /// 선택한 후보 옵션 id로 투표 참여를 요청한다.
    /// 재투표 모드를 종료하면, 성공 시 Feature가 dateVote를 재조회해 `hasVotedDate`가 true로 유지되어 완료 화면으로 복귀한다.
    private func submitVote() {
        switch selection.resolveSubmit(myVotedIds: store.myVotedDateOptionIds) {
        case .skip:
            return

        case let .submit(optionIds):
            store.send(.dateVoteSubmitTapped(optionIds: optionIds))
        }
    }

    private func toggleSelectAll() {
        guard !hasVoted else { return }

        selection.toggleSelectAll(allIds: allOptionIds)
    }
}

// MARK: - Date Vote Top Area

private struct DateVoteTopArea: View {
    let deadline: String?
    let participantCount: Int
    let participationRatio: Double

    @Dependency(\.calendar) private var calendar
    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText("날짜 투표하기", textStyle: .titleMediumEmphasized)
                .foregroundStyle(Colors.gray900)

            BangawoText(DateVoteFormatter.deadlineLabel(deadline, now: now, calendar: calendar), textStyle: .bodyXSmall)
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
        .onReceive(timer) { now = $0 }
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
    let selectedOptionIds: Set<Int>
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(options) { option in
                DateVoteRow(
                    option: option,
                    hasVoted: hasVoted,
                    isSelected: hasVoted ? option.isMyVote : selectedOptionIds.contains(option.id),
                    onSelect: { onSelect(option.id) }
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

    static func deadlineLabel(_ raw: String?, now: Date, calendar: Calendar) -> String {
        guard
            let raw,
            let date = DateFormatterStore.date(from: raw, format: "yyyy-MM-dd"),
            // 임시: deadline에 시각이 없어 해당 날짜의 23:59:59를 마감 시각으로 사용
            let deadline = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)
        else { return "" }

        let remaining = max(0, Int(deadline.timeIntervalSince(now)))
        let days = remaining / 86400
        let hours = (remaining % 86400) / 3600
        let minutes = (remaining % 3600) / 60
        let seconds = remaining % 60

        let time = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        let dayPrefix = days > 0 ? "+\(days)일 " : ""
        return "투표 시작일 기준 \(dayPrefix)\(time) 남았어요"
    }
}

// MARK: - Constants

private enum Metric {
    static let progressBarHeight: CGFloat = 10
    static let checkIconLength: CGFloat = 18
    static let voteLabelFontSize: CGFloat = 12
}

private enum Constant {
    static let mutedIconHex = "#888692"
    static let progressTrackHex = "#E2E1E5"
}
