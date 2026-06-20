//
//  MeetingDateSelectionView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture
import DesignSystem

struct MeetingDateSelectionView: View {
    let store: StoreOf<MeetingDateSelectionFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { dismiss() },
                title: "약속 날짜 정하기"
            )

            DateSelectionSegmentedPicker(
                selection: Binding(
                    get: { store.selectedTab },
                    set: { store.send(.tabSelected($0)) }
                )
            )
                .padding(.horizontal, Spacing.spacing400)
                .padding(.top, Spacing.spacing300)

            switch store.selectedTab {
            case .date:
                DateDesignationView(
                    store: store.scope(state: \.dateDesignation, action: \.dateDesignation)
                )

            case .periodVote:
                PeriodVoteView(
                    store: store.scope(state: \.periodVote, action: \.periodVote)
                )
            }

            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            ActionButton(
                buttonLayout: .single(
                    title: "다음",
                    isDisabled: !store.isNextEnabled,
                    action: { store.send(.nextButtonTapped) }
                )
            )
        }
        .background(.white)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - DateDesignationView

private struct DateDesignationView: View {
    let store: StoreOf<DateDesignationFeature>

    var body: some View {
        VStack(spacing: 0) {
            MeetingDateConfirmationNotice()
                .padding(.horizontal, Spacing.spacing400)
                .padding(.top, Spacing.spacing200)

            MeetingDateSelectionField(
                title: "날짜",
                placeholder: "날짜 선택하기",
                iconName: "ic_calender_24",
                text: store.selectedDateText
            ) {
                store.send(.dateFieldTapped)
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.top, Spacing.spacing400)
        }
    }
}

// MARK: - PeriodVoteView

private struct PeriodVoteView: View {
    let store: StoreOf<PeriodVoteFeature>

    var body: some View {
        VStack(spacing: 0) {
            MeetingDateConfirmationNotice()
                .padding(.horizontal, Spacing.spacing400)
                .padding(.top, Spacing.spacing200)

            MeetingDateSelectionField(
                title: "날짜",
                placeholder: "날짜 선택하기",
                iconName: "ic_calender_24",
                text: store.selectedDateText
            ) {
                store.send(.dateFieldTapped)
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.top, Spacing.spacing400)

            MeetingDateSelectionField(
                title: "투표 마감 시간",
                placeholder: "시간을 선택해 주세요",
                iconName: "ic_colck_24",
                text: store.deadlineText
            ) {
                store.send(.deadlineFieldTapped)
            }
            .padding(.horizontal, Spacing.spacing400)
            .padding(.top, Spacing.spacing400)
        }
    }
}

// MARK: - MeetingDateConfirmationNotice

private struct MeetingDateConfirmationNotice: View {
    var body: some View {
        HStack(spacing: Spacing.spacing100) {
            if let icon = Image.assetIfExists(named: "ic_circle_alert_fill_16") {
                icon
                    .renderingMode(.template)
                    .frame(width: Sizing.sizing100, height: Sizing.sizing100)
            }

            MeetingDateConfirmationNoticeText()
        }
        .foregroundStyle(Colors.green600)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.all, Spacing.spacing250)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(Colors.green100)
        )
    }
}

// MARK: - MeetingDateConfirmationNoticeText

private struct MeetingDateConfirmationNoticeText: View {
    var body: some View {
        Text(attributedText)
    }

    private var attributedText: AttributedString {
        styledText("바로 확정", textStyle: .labelSmallEmphasized)
            + styledText(" 선택 시 일정이 확정됩니다.", textStyle: .bodySmall)
    }

    private func styledText(_ content: String, textStyle: CustomSizeFont) -> AttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = CustomSizeFont.bodySmall.lineHeight
        paragraphStyle.maximumLineHeight = CustomSizeFont.bodySmall.lineHeight

        var attributed = AttributedString(content)
        attributed.paragraphStyle = paragraphStyle
        attributed.font = .custom("PretendardVariable-\(textStyle.fontFamily)", size: textStyle.size)
        attributed.kern = textStyle.letterSpacing * textStyle.size
        return attributed
    }
}

// MARK: - DateSelectionSegmentedPicker

private struct DateSelectionSegmentedPicker: View {
    @Binding var selection: MeetingDateSelectionTab
    @Namespace private var namespace

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MeetingDateSelectionTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0.12)) {
                        selection = tab
                    }
                } label: {
                    ZStack {
                        if selection == tab {
                            Capsule()
                                .fill(.white)
                                .shadow(color: Colors.grayAlpha200, radius: BorderRadius.borderRadiusFull, x: 0, y: 1)
                                .matchedGeometryEffect(id: "selectedTab", in: namespace)
                        }

                        BangawoText(tab.rawValue, textStyle: .titleMedium)
                            .foregroundStyle(selection == tab ? Colors.gray900 : Colors.gray700)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(height: Metric.itemHeight)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Metric.containerPadding)
        .background(
            Capsule()
                .fill(Colors.gray200)
        )
    }
}

private extension DateSelectionSegmentedPicker {
    enum Metric {
        static let containerPadding: CGFloat = Spacing.spacing100
        static let itemHeight: CGFloat = 46
    }
}

#Preview {
    BangawoPreview {
        MeetingDateSelectionView(store: Store(initialState: MeetingDateSelectionFeature.State()) {
            MeetingDateSelectionFeature()
        })
    }
}
