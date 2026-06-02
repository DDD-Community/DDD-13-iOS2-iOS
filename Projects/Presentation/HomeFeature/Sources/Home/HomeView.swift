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

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    NavigationMain(
                        background: .clear,
                        trailingIcons: [
                            NavigationIconItem(
                                icon: .bell24,
                                showsBadge: store.hasUnreadNotifications
                            ) { store.send(.notificationButtonTapped) },
                            NavigationIconItem(icon: .user24) {
                                store.send(.myPageButtonTapped)
                            }
                        ]
                    )

                    Tab(
                        labels: ["모임", "리마인더"],
                        selectedIndex: Binding(
                            get: { store.selectedTabIndex },
                            set: { store.send(.tabSelected($0)) }
                        ),
                        variant: .scrollable,
                        size: .large
                    )

                    if store.selectedTabIndex == 0 {
                        GroupListContent(
                            groups: store.groups,
                            onCreateTapped: { store.send(.createGroupRowTapped) },
                            onGroupTapped: { store.send(.groupCardTapped($0)) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Colors.gray200.ignoresSafeArea())

                FAB(
                    isPressed: $isFABExpanded,
                    menuItems: [
                        Menu.Item(label: "모임 만들기", icon: .Asset.icPlus24) {
                            isFABExpanded = false
                            store.send(.fabCreateGroupTapped)
                        },
                        Menu.Item(label: "모임 참여하기", icon: .Asset.icUsersPlus24) {
                            isFABExpanded = false
                            store.send(.fabJoinGroupTapped)
                        }
                    ]
                )
                .padding(.trailing, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing400)
            }
            .onAppear { store.send(.onAppear) }
            .fullScreenCover(item: $store.scope(state: \.creationView, action: \.creationView)) { creationStore in
                GroupCreationView(store: creationStore)
            }
        } destination: { pathStore in
            switch pathStore.case {
            case let .detail(detailStore):
                GroupDetailView(store: detailStore)
            }
        }
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

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius250
        static let gradientEndRadius: CGFloat = 240
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.spacing300) {
                Image.Asset.icPlus24
                    .renderingMode(.template)
                    .foregroundStyle(Colors.gray800)

                BangawoText("모임 생성하기", textStyle: .titleLarge)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Spacing.spacing500)
            .padding(.horizontal, Spacing.spacing400)
            .background(background)
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.spacing600)
        .padding(.horizontal, Spacing.spacing400)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: Metric.cornerRadius)
            .fill(
                RadialGradient(
                    colors: [Colors.grayAlpha50, Colors.grayAlpha200],
                    center: .center,
                    startRadius: 0,
                    endRadius: Metric.gradientEndRadius
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Metric.cornerRadius)
                    .stroke(Colors.gray50, lineWidth: BorderWidth.borderWidth100)
            )
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

// MARK: - Previews

#Preview("모임 없음") {
    HomeView(
        store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
        }
    )
}
