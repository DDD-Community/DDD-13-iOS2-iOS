//
//  RootView.swift
//  RootFeature
//

import SwiftUI

import ComposableArchitecture

import AuthFlowFeature
import HomeFeature

public struct RootView: View {
    @Bindable private var store: StoreOf<RootFeature>

    public init(store: StoreOf<RootFeature>) {
        self.store = store
    }

    public var body: some View {
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
