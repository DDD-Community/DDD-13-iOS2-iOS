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
    let store: StoreOf<SelectPlaceFeature>

    var body: some View {
        switch store.selectedSubTab {
        case .placeMap:
            PlaceMapTab(store: store.scope(state: \.placeMap, action: \.placeMap))

        case .pickedPlace:
            PickedPlaceTab(store: store.scope(state: \.pickedPlace, action: \.pickedPlace))
        }
    }
}

// MARK: - Preview

#if DEBUG
private struct SelectPlaceViewPreview: View {
    private let store: StoreOf<SelectPlaceFeature>

    init(
        selectedSubTabIndex: Int = 0,
        pickedPlaces: [PickedPlace] = PickedPlace.mock,
        isHost: Bool = false
    ) {
        var state = SelectPlaceFeature.State(pickedPlaces: pickedPlaces, isHost: isHost)
        state.selectedSubTabIndex = selectedSubTabIndex
        self.store = Store(initialState: state) {
            SelectPlaceFeature()
        }
    }

    var body: some View {
        SelectPlaceView(store: store)
    }
}

#Preview("장소보기 탭") {
    BangawoPreview {
        SelectPlaceViewPreview()
    }
}

#Preview("담은 장소 탭 - 호스트") {
    BangawoPreview {
        SelectPlaceViewPreview(selectedSubTabIndex: 1, isHost: true)
    }
}

#Preview("담은 장소 탭 - 빈 상태") {
    BangawoPreview {
        SelectPlaceViewPreview(selectedSubTabIndex: 1, pickedPlaces: [])
    }
}
#endif
