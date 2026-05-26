//
//  HomeView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(Color.black)
            Text("Home (임시)")
                .font(.title2.bold())
            Text("회원가입 플로우가 끝나면 여기로 진입합니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { store.send(.onAppear) }
    }
}
