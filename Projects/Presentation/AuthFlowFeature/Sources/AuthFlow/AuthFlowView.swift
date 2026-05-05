//
//  AuthFlowView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture

public struct AuthFlowView: View {
    @Bindable private var store: StoreOf<AuthFlowFeature>

    public init(store: StoreOf<AuthFlowFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            TempLoginView(store: store.scope(state: \.temp, action: \.temp))
        } destination: { pathStore in
            switch pathStore.case {
            case let .terms(termsStore):
                TermsAgreementView(store: termsStore)

            case let .profile(profileStore):
                ProfileInputView(store: profileStore)

            case let .departure(departureStore):
                DepartureSearchView(store: departureStore)
            }
        }
    }
}
