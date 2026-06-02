//
//  RootView.swift
//  RootFeature
//

import SwiftUI

import ComposableArchitecture

import AuthFlowFeature
import HomeFeature

import Utill

public struct RootView: View {
    @Bindable private var store: StoreOf<RootFeature>
    @AppStorage(UserDefaultsKey.isLogin) private var isLogin: Bool = false

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
        .onChange(of: isLogin) { _, newValue in
            if !newValue {
                store.send(.sessionExpired)
            }
        }
    }
}
