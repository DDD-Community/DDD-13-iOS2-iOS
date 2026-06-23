//
//  VoteDeadlineSheetContent.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture
import DesignSystem

struct VoteDeadlineSheetContent: View {
    let store: StoreOf<PeriodVoteFeature>

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: Spacing.spacing200) {
                BangawoText("투표 마감일을 설정해주세요", textStyle: .titleLarge)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    store.send(.deadlineSheetDismissed)
                } label: {
                    Image.Asset.icClose24
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Metric.closeButtonLength, height: Metric.closeButtonLength)
                        .foregroundStyle(Colors.gray500)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, Spacing.spacing300)

            ForEach(VoteDeadlineOption.allCases) { option in
                VoteDeadlineOptionRow(
                    title: option.rawValue,
                    isSelected: store.deadlineDraft == option
                ) {
                    store.send(.deadlineOptionSelected(option), animation: nil)
                }
            }
        }
    }
}

private extension VoteDeadlineSheetContent {
    enum Metric {
        static let closeButtonLength: CGFloat = 24
    }
}

private struct VoteDeadlineOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing200) {
                BangawoText(title, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Checkbox(variant: .ghost, state: .enabled, size: .medium)
                    .opacity(isSelected ? 1 : 0)
            }
            .padding(.vertical, Spacing.spacing350)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
