//
//  HomeView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>
    @State private var sheetDetents: Set<PresentationDetent> = [.fraction(0.5)]

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                HomeNavigationBar()
                    .padding(.horizontal, Spacing.spacing300)

                if !store.meetings.isEmpty {
                    MeetingFilterCarousel(
                        selectedFilter: store.selectedFilter,
                        onFilterTapped: { store.send(.filterTapped($0)) }
                    )
                    .padding(.top, Spacing.spacing250)
                }

                MeetingListContent(
                    meetings: store.filteredMeetings,
                    onCreateTapped: { store.send(.createMeetingRowTapped) }
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(.gray200)

            HomeFAB(
                isExpanded: store.isFABExpanded,
                onTap: { store.send(.fabTapped) },
                onCreateMeeting: { store.send(.fabCreateMeetingTapped) },
                onJoinMeeting: { store.send(.fabJoinMeetingTapped) }
            )
            .padding(.trailing, Spacing.spacing300)
            .padding(.bottom, Spacing.spacing400)
        }
        .onAppear { store.send(.onAppear) }
        .sheet(item: $store.scope(state: \.creationSheet, action: \.creationSheet)) { sheetStore in
            MeetingCreationSheet(store: sheetStore)
                .presentationDetents(sheetDetents)
                .presentationDragIndicator(sheetStore.step == .purpose ? .visible : .hidden)
                .onAppear { sheetDetents = [.fraction(0.5)] }
                .onChange(of: sheetStore.step) { _, step in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        sheetDetents = step == .purpose
                            ? [.fraction(0.5), .fraction(0.9)]
                            : [.fraction(0.5)]
                    }
                }
        }
    }
}

// MARK: - Navigation Bar

private struct HomeNavigationBar: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("반가워")
                .pretendardCustomFont(textStyle: .heading1)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: Spacing.spacing200) {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius100)
                    .fill(.gray400)
                    .frame(width: Sizing.sizing200, height: Sizing.sizing200)

                RoundedRectangle(cornerRadius: BorderRadius.borderRadius100)
                    .fill(.gray400)
                    .frame(width: Sizing.sizing200, height: Sizing.sizing200)
            }
        }
        .frame(height: 56)
    }
}

// MARK: - Filter Carousel

private struct MeetingFilterCarousel: View {
    let selectedFilter: MeetingFilter
    let onFilterTapped: (MeetingFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing200) {
                ForEach(MeetingFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: selectedFilter == filter
                    ) {
                        onFilterTapped(filter)
                    }
                }
            }
            .padding(.horizontal, Spacing.spacing300)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(title)
                .pretendardCustomFont(textStyle: .body2Medium)
                .foregroundStyle(isSelected ? Color(hex: "FFFFFF") : Color(hex: "545454"))
                .padding(.horizontal, Spacing.spacing250)
                .padding(.vertical, Spacing.spacing150)
                .background(
                    Capsule()
                        .fill(isSelected ? Color(hex: "FF3C27") : Color(hex: "EDEDED"))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meeting List

private struct MeetingListContent: View {
    let meetings: [Meeting]
    let onCreateTapped: () -> Void

    var body: some View {
        if meetings.isEmpty {
            CreateMeetingRow(onTap: onCreateTapped)
                .padding(.horizontal, Spacing.spacing300)
                .padding(.top, Spacing.spacing250)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.spacing250) {
                    ForEach(meetings) { meeting in
                        MeetingCard(meeting: meeting)
                    }
                }
                .padding(.horizontal, Spacing.spacing300)
                .padding(.top, Spacing.spacing250)
                .padding(.bottom, 80)
            }
        }
    }
}

private struct CreateMeetingRow: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing300) {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                    .fill(.gray300)
                    .frame(width: Sizing.sizing550, height: Sizing.sizing550)
                    .overlay(
                        Text("+")
                            .pretendardCustomFont(textStyle: .heading1)
                            .foregroundStyle(.gray600)
                    )

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    Text("모임 생성하기")
                        .pretendardCustomFont(textStyle: .bodyBold)
                        .foregroundStyle(.gray900)

                    Text("새로운 모임을 만들어보세요")
                        .pretendardCustomFont(textStyle: .body2Regular)
                        .foregroundStyle(.gray600)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Spacing.spacing300)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .fill(Color(hex: "FFFFFF"))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meeting Card

private struct MeetingCard: View {
    let meeting: Meeting

    var body: some View {
        VStack(spacing: Spacing.spacing250) {
            MeetingCardTopArea(meeting: meeting)
            MeetingCardBottomArea(participantCount: meeting.participantCount)
        }
        .padding(Spacing.spacing300)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                .fill(Color(hex: "FFFFFF"))
        )
    }
}

private struct MeetingCardTopArea: View {
    let meeting: Meeting

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.spacing250) {
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(.gray300)
                .frame(width: Sizing.sizing550, height: Sizing.sizing550)

            VStack(alignment: .leading, spacing: Spacing.spacing100) {
                Text(meeting.title)
                    .pretendardCustomFont(textStyle: .bodyBold)
                    .foregroundStyle(.gray900)

                Text(meeting.hashtag)
                    .pretendardCustomFont(textStyle: .body2Regular)
                    .foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            MeetingStatusBadge(status: meeting.status)
        }
    }
}

private struct MeetingStatusBadge: View {
    let status: MeetingFilter

    private var badgeColor: Color {
        switch status {
        case .all: return Color(hex: "D4D4D4")
        case .inProgress: return Color(hex: "FF6B5C")
        case .confirmed: return Color(hex: "4D6399")
        case .ended: return Color(hex: "A1A1A1")
        }
    }

    var body: some View {
        Text(status.rawValue)
            .pretendardCustomFont(textStyle: .caption)
            .foregroundStyle(Color(hex: "FFFFFF"))
            .padding(.horizontal, Spacing.spacing200)
            .padding(.vertical, Spacing.spacing100)
            .background(Capsule().fill(badgeColor))
    }
}

private struct MeetingCardBottomArea: View {
    let participantCount: Int

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            OverlappingCircles(count: participantCount)

            Text("\(participantCount)명")
                .pretendardCustomFont(textStyle: .body2Regular)
                .foregroundStyle(.gray700)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OverlappingCircles: View {
    let count: Int

    private enum Metric {
        static let circleSize: CGFloat = Sizing.sizing200
        static let overlap: CGFloat = Spacing.spacing200
        static let maxVisible: Int = 3
    }

    var body: some View {
        HStack(spacing: -Metric.overlap) {
            ForEach(0..<min(count, Metric.maxVisible), id: \.self) { _ in
                Circle()
                    .fill(.gray400)
                    .frame(width: Metric.circleSize, height: Metric.circleSize)
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "FFFFFF"), lineWidth: 2)
                    )
            }
        }
    }
}

// MARK: - FAB

private struct HomeFAB: View {
    let isExpanded: Bool
    let onTap: () -> Void
    let onCreateMeeting: () -> Void
    let onJoinMeeting: () -> Void

    private enum Metric {
        static let fabSize: CGFloat = Sizing.sizing600
        static let menuSpacing: CGFloat = 7
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: Metric.menuSpacing) {
            if isExpanded {
                FABMenu(
                    onCreateMeeting: onCreateMeeting,
                    onJoinMeeting: onJoinMeeting
                )
            }

            Button(action: onTap) {
                Circle()
                    .fill(Color(hex: "FF3C27"))
                    .frame(width: Metric.fabSize, height: Metric.fabSize)
                    .overlay(
                        Text("+")
                            .pretendardCustomFont(textStyle: .heading1)
                            .foregroundStyle(Color(hex: "FFFFFF"))
                    )
                    .shadow(
                        color: Color(hex: "FF3C27").opacity(0.3),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct FABMenu: View {
    let onCreateMeeting: () -> Void
    let onJoinMeeting: () -> Void

    private enum Metric {
        static let width: CGFloat = 160
        static let height: CGFloat = 120
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onCreateMeeting) {
                Text("모임 만들기")
                    .pretendardCustomFont(textStyle: .body2Medium)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)

            Divider()

            Button(action: onJoinMeeting) {
                Text("모임 참여하기")
                    .pretendardCustomFont(textStyle: .body2Medium)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)
        }
        .frame(width: Metric.width, height: Metric.height)
        .background(Color(hex: "FFFFFF"))
        .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
        .shadow(
            color: Color(hex: "D4D4D4").opacity(0.4),
            radius: 8,
            x: 0,
            y: 4
        )
    }
}

// MARK: - Previews

#Preview("모임 있음") {
    var state = HomeFeature.State()
    state.meetings = [
        Meeting(
            id: UUID(),
            title: "주말 러닝 모임",
            hashtag: "#러닝 #건강 #운동",
            status: .inProgress,
            participantCount: 5
        ),
        Meeting(
            id: UUID(),
            title: "독서 토론 클럽",
            hashtag: "#독서 #인문학",
            status: .confirmed,
            participantCount: 8
        ),
        Meeting(
            id: UUID(),
            title: "요리 교실",
            hashtag: "#요리 #취미",
            status: .ended,
            participantCount: 3
        ),
    ]
    return HomeView(
        store: Store(initialState: state) {
            HomeFeature()
        }
    )
}

#Preview("모임 없음") {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
