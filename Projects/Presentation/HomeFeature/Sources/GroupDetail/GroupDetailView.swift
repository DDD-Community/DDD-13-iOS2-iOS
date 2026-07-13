//
//  GroupDetailView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import CoreDependencies
import DesignSystem
import Entity

public struct GroupDetailView: View {
    @Bindable private var store: StoreOf<GroupDetailFeature>

    @Environment(\.dismiss) private var dismiss

    @State private var isMoreMenuPresented = false

    public init(store: StoreOf<GroupDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { dismiss() },
                trailingIcons: [
                    NavigationIconItem(icon: .userPlus24) { store.send(.inviteButtonTapped) },
                    NavigationIconItem(icon: .verticalMenu24) { isMoreMenuPresented.toggle() }
                ]
            )

            Tab(
                labels: store.tabs.map(\.label),
                selectedIndex: tabBinding,
                variant: .fixed,
                size: .small
            )

            TabContent(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Colors.gray200)
        .overlay {
            if isMoreMenuPresented {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { isMoreMenuPresented = false }

                    DesignSystem.Menu(items: [
                        .init(label: store.home.isMeHost ? "그룹 종료" : "그룹 나가기") {
                            store.send(store.home.isMeHost ? .endGroupTapped : .leaveGroupTapped)
                            isMoreMenuPresented = false
                        }
                    ])
                    .offset(x: Metric.moreMenuOffsetX, y: Metric.moreMenuOffsetY)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .menuSheet(
            isPresented: $store.isInviteSheetPresented,
            title: "친구 초대하기",
            items: [
                .init(label: "카카오톡 공유하기", icon: .Asset.icShare24) {
                    store.send(.kakaoShareTapped)
                },
                .init(label: "링크 복사하기", icon: .Asset.icCopy24) {
                    store.send(.inviteLinkCopyTapped)
                }
            ]
        )
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private var tabBinding: Binding<Int> {
        Binding(
            get: { store.selectedTabIndex },
            set: { store.send(.tabSelected($0)) }
        )
    }
}

// MARK: - Metric

private enum Metric {
    /// 케밥 아이콘 트레일링 인셋(`NavigationPage`의 trailing padding)만큼 우측에서 안쪽으로 정렬.
    static let moreMenuOffsetX: CGFloat = -Spacing.spacing300
    /// `NavigationPage` 높이(`Sizing.sizing450` + 상하 `Spacing.spacing150`) 아래로 내려 아이콘 바로 밑에 배치.
    static let moreMenuOffsetY: CGFloat = Sizing.sizing450 + Spacing.spacing150 * 2 + Spacing.spacing100
}

// MARK: - Tab Content

private struct TabContent: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        Group {
            switch store.selectedTab {
            case .home:
                HomeTab(store: store.scope(state: \.home, action: \.home))

            case .myPlace:
                MyPlaceTab(store: store.scope(state: \.myPlace, action: \.myPlace))
            }
        }
        // HomeTab을 트리에서 제거하지 않고 위에 덮는다.
        // 최초 로드에만 노출되며, HomeTab의 .task 재마운트 루프를 유발하지 않는다.
        .overlay {
            if store.home.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Colors.gray200)
            }
        }
    }
}

// MARK: - Preview

private struct GroupDetailPreview: View {
    let groupIndex: Int

    @State private var group: Entity.Group?

    var body: some View {
        NavigationStack {
            if let group {
                GroupDetailView(
                    store: Store(initialState: GroupDetailFeature.State(group: group)) {
                        GroupDetailFeature()
                    } withDependencies: {
                        $0.groupClient = .previewValue
                    }
                )
            } else {
                ProgressView()
                    .task {
                        let groups = (try? await GroupClient.previewValue.fetchGroups()) ?? []
                        group = groups.indices.contains(groupIndex) ? groups[groupIndex] : groups.first
                    }
            }
        }
    }
}

#Preview("멤버 있음") {
    BangawoPreview {
        GroupDetailPreview(groupIndex: 0)
    }
}

#Preview("멤버 없음") {
    GroupDetailPreview(groupIndex: 1)
}
