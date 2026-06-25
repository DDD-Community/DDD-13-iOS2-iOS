//
//  PickPlaceView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 장소 투표 후보 담기 화면.
/// GroupDetail과 동일하게 NavigationPage + Tab + TabContent로 구성한다.
struct PickPlaceView: View {
    @Bindable private var store: StoreOf<PickPlaceFeature>

    init(store: StoreOf<PickPlaceFeature>) {
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
        .toolbar(.hidden, for: .navigationBar)
        .task { store.send(.onAppear) }
    }

    private var subTabBinding: Binding<Int> {
        Binding(
            get: { store.selectedSubTabIndex },
            set: { store.send(.tabSelected($0)) }
        )
    }
}

// MARK: - Tab Content

private struct TabContent: View {
    let store: StoreOf<PickPlaceFeature>

    var body: some View {
        switch store.selectedSubTab {
        case .recommendedPlaceMap:
            RecommendedPlaceMapTab(store: store.scope(state: \.recommendedPlaceMap, action: \.recommendedPlaceMap))

        case .pickedPlace:
            PickedPlaceTab(store: store.scope(state: \.pickedPlace, action: \.pickedPlace))
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct PickPlaceViewPreview: View {
    private let store: StoreOf<PickPlaceFeature>

    init(
        selectedSubTabIndex: Int = 0,
        pickedPlaces: [PickedPlace] = PickedPlace.mock,
        isHost: Bool = false
    ) {
        var state = PickPlaceFeature.State(pickedPlaces: pickedPlaces, isHost: isHost)
        state.selectedSubTabIndex = selectedSubTabIndex
        self.store = Store(initialState: state) {
            PickPlaceFeature()
        }
    }

    var body: some View {
        PickPlaceView(store: store)
    }
}

#Preview("장소보기 탭") {
    BangawoPreview {
        PickPlaceViewPreview()
    }
}

#Preview("담은 장소 탭 - 호스트") {
    BangawoPreview {
        PickPlaceViewPreview(selectedSubTabIndex: 1, isHost: true)
    }
}

#Preview("담은 장소 탭 - 빈 상태") {
    BangawoPreview {
        PickPlaceViewPreview(selectedSubTabIndex: 1, pickedPlaces: [])
    }
}
#endif
