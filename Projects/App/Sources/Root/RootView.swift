//
//  RootView.swift
//  App
//

import AuthFlowFeature
import ComposableArchitecture
import HomeFeature
import SwiftUI

struct RootView: View {
    @Bindable private var store: StoreOf<RootFeature>

    init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    var body: some View {
        Group {
            switch store.mode {
            case .auth:
                AuthFlowView(store: store.scope(state: \.auth, action: \.auth))

            case .main:
                HomeView(store: store.scope(state: \.home, action: \.home))
            }
        }
        .onAppear { store.send(.onAppear) }
    }
}
