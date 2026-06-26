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

    public init(store: StoreOf<GroupDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { dismiss() },
                trailingIcons: [
                    NavigationIconItem(icon: .userPlus24) {},
                    NavigationIconItem(icon: .verticalMenu24) {}
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
        .toolbar(.hidden, for: .navigationBar)
        .task { store.send(.home(.onAppear)) }
    }

    private var tabBinding: Binding<Int> {
        Binding(
            get: { store.selectedTabIndex },
            set: { store.send(.tabSelected($0)) }
        )
    }
}

// MARK: - Tab Content

private struct TabContent: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        if store.home.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            switch store.selectedTab {
            case .home:
                HomeTab(store: store.scope(state: \.home, action: \.home))

            case .myPlace:
                MyPlaceTab(store: store.scope(state: \.myPlace, action: \.myPlace))
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
