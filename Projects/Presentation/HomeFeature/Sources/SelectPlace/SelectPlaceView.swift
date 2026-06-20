//
//  SelectPlaceView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 장소 투표 후보 담기 화면.
/// GroupDetail과 동일하게 NavigationPage + Tab + TabContent로 구성한다.
struct SelectPlaceView: View {
    @Bindable private var store: StoreOf<SelectPlaceFeature>

    init(store: StoreOf<SelectPlaceFeature>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { store.send(.backButtonTapped) }
            )

            Tab(
                labels: store.subTabs.map(\.label),
                selectedIndex: subTabBinding,
                variant: .fixed,
                size: .small
            )

            TabContent(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Colors.gray200)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var subTabBinding: Binding<Int> {
        Binding(
            get: { store.selectedSubTabIndex },
            set: { store.send(.subTabSelected($0)) }
        )
    }
}

// MARK: - Tab Content

private struct TabContent: View {
    let store: StoreOf<SelectPlaceFeature>

    var body: some View {
        switch store.selectedSubTab {
        case .placeMap:
            PlaceMapTab(store: store)

        case .pickedPlace:
            PickedPlaceTab(store: store)
        }
    }
}
