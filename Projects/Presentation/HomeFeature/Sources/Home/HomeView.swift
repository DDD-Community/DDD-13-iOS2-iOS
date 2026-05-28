//
//  HomeView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture
import DesignSystem
import Entity

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>
    @State private var isFABExpanded = false
    @State private var sheetDetents: Set<PresentationDetent> = [.fraction(0.5)]

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    HomeNavigationBar()
                        .padding(.horizontal, Spacing.spacing300)

                    if !store.groups.isEmpty {
                        GroupFilterCarousel(
                            selectedFilter: store.selectedFilter,
                            onFilterTapped: { store.send(.filterTapped($0)) }
                        )
                        .padding(.top, Spacing.spacing250)
                    }

                    GroupListContent(
                        groups: store.filteredGroups,
                        onCreateTapped: { store.send(.createGroupRowTapped) },
                        onGroupTapped: { store.send(.groupCardTapped($0)) }
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(.gray200)

                HomeFAB(
                    isExpanded: $isFABExpanded,
                    onCreateGroup: { store.send(.fabCreateGroupTapped) },
                    onJoinGroup: { store.send(.fabJoinGroupTapped) }
                )
                .padding(.trailing, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing400)
            }
            .onAppear { store.send(.onAppear) }
            .sheet(item: $store.scope(state: \.creationSheet, action: \.creationSheet)) { sheetStore in
                GroupCreationSheet(store: sheetStore)
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
        } destination: { pathStore in
            switch pathStore.case {
            case let .detail(detailStore):
                GroupDetailView(store: detailStore)
            }
        }
    }
}

// MARK: - Navigation Bar

private struct HomeNavigationBar: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("반가워")
                .pretendardCustomFont(textStyle: .headingSmall)
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

private struct GroupFilterCarousel: View {
    let selectedFilter: GroupFilter
    let onFilterTapped: (GroupFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing200) {
                ForEach(GroupFilter.allCases, id: \.self) { filter in
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
                .pretendardCustomFont(textStyle: .bodyMedium)
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

// MARK: - Group List

private struct GroupListContent: View {
    let groups: [Entity.Group]
    let onCreateTapped: () -> Void
    let onGroupTapped: (Entity.Group) -> Void

    var body: some View {
        if groups.isEmpty {
            CreateGroupRow(onTap: onCreateTapped)
                .padding(.horizontal, Spacing.spacing300)
                .padding(.top, Spacing.spacing250)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                LazyVStack(spacing: Spacing.spacing250) {
                    ForEach(groups) { group in
                        GroupCard(group: group, onTap: { onGroupTapped(group) })
                    }
                }
                .padding(.horizontal, Spacing.spacing300)
                .padding(.top, Spacing.spacing250)
                .padding(.bottom, 80)
            }
        }
    }
}

private struct CreateGroupRow: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing300) {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                    .fill(.gray300)
                    .frame(width: Sizing.sizing550, height: Sizing.sizing550)
                    .overlay(
                        Text("+")
                            .pretendardCustomFont(textStyle: .headingSmall)
                            .foregroundStyle(.gray600)
                    )

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    Text("모임 생성하기")
                        .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                        .foregroundStyle(.gray900)

                    Text("새로운 모임을 만들어보세요")
                        .pretendardCustomFont(textStyle: .bodySmall)
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

// MARK: - Group Card

private struct GroupCard: View {
    let group: Entity.Group
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.spacing250) {
                GroupCardTopArea(group: group)
                GroupCardBottomArea(memberCount: group.memberCount)
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

private struct GroupCardTopArea: View {
    let group: Entity.Group

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.spacing250) {
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(.gray300)
                .frame(width: Sizing.sizing550, height: Sizing.sizing550)

            VStack(alignment: .leading, spacing: Spacing.spacing100) {
                Text(group.name)
                    .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                    .foregroundStyle(.gray900)

                Text(group.themeTagDisplay)
                    .pretendardCustomFont(textStyle: .bodySmall)
                    .foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            GroupStatusBadge(status: group.listStatus)
        }
    }
}

private struct GroupStatusBadge: View {
    let status: GroupListStatus

    private var badgeColor: Color {
        switch status {
        case .inProgress: return Color(hex: "FF6B5C")
        case .confirmed: return Color(hex: "4D6399")
        case .ended: return Color(hex: "A1A1A1")
        case .unknown: return Color(hex: "D4D4D4")
        }
    }

    private var displayText: String {
        switch status {
        case .inProgress: return "진행중"
        case .confirmed: return "확정"
        case .ended: return "종료"
        case .unknown(let raw): return raw
        }
    }

    var body: some View {
        Text(displayText)
            .pretendardCustomFont(textStyle: .labelSmall)
            .foregroundStyle(Color(hex: "FFFFFF"))
            .padding(.horizontal, Spacing.spacing200)
            .padding(.vertical, Spacing.spacing100)
            .background(Capsule().fill(badgeColor))
    }
}

private struct GroupCardBottomArea: View {
    let memberCount: Int

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            OverlappingCircles(count: memberCount)

            Text("\(memberCount)명")
                .pretendardCustomFont(textStyle: .bodySmall)
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
    @Binding private var isExpanded: Bool
    private let onCreateGroup: () -> Void
    private let onJoinGroup: () -> Void

    init(
        isExpanded: Binding<Bool>,
        onCreateGroup: @escaping () -> Void,
        onJoinGroup: @escaping () -> Void
    ) {
        self._isExpanded = isExpanded
        self.onCreateGroup = onCreateGroup
        self.onJoinGroup = onJoinGroup
    }

    private enum Metric {
        static let fabSize: CGFloat = Sizing.sizing600
        static let menuSpacing: CGFloat = 7
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: Metric.menuSpacing) {
            if isExpanded {
                FABMenu(
                    onCreateGroup: {
                        isExpanded = false
                        onCreateGroup()
                    },
                    onJoinGroup: {
                        isExpanded = false
                        onJoinGroup()
                    }
                )
            }

            Button(action: { isExpanded.toggle() }) {
                Circle()
                    .fill(Color(hex: "FF3C27"))
                    .frame(width: Metric.fabSize, height: Metric.fabSize)
                    .overlay(
                        Text("+")
                            .pretendardCustomFont(textStyle: .headingSmall)
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
    let onCreateGroup: () -> Void
    let onJoinGroup: () -> Void

    private enum Metric {
        static let width: CGFloat = 160
        static let height: CGFloat = 120
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onCreateGroup) {
                Text("모임 만들기")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(.gray900)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)

            Divider()

            Button(action: onJoinGroup) {
                Text("모임 참여하기")
                    .pretendardCustomFont(textStyle: .bodyMedium)
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

#Preview("모임 없음") {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
