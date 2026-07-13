//
//  AuthFlowView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import StationSearchFeature

public struct AuthFlowView: View {
    @Bindable private var store: StoreOf<AuthFlowFeature>

    public init(store: StoreOf<AuthFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            LoginView(store: store.scope(state: \.login, action: \.login)) // 기본 로그인뷰 부터 스택 쌓고
                .toolbar(.hidden, for: .navigationBar)
        } destination: { pathStore in
            switch pathStore.case {
            case let .terms(termsStore):
                TermsAgreementView(store: termsStore)
                    .toolbar(.hidden, for: .navigationBar)

            case let .profile(profileStore):
                ProfileInputView(store: profileStore)
                    .toolbar(.hidden, for: .navigationBar)

            case let .departure(departureStore):
                DepartureSearchView(store: departureStore)
                    .toolbar(.hidden, for: .navigationBar)
            }
        }
        .stationSearchSheet(item: $store.scope(state: \.stationSearch, action: \.stationSearch))
    }
}
