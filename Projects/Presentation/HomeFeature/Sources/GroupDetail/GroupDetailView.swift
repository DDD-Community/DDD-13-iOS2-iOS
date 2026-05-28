//
//  GroupDetailView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct GroupDetailView: View {
    private let store: StoreOf<GroupDetailFeature>

    public init(store: StoreOf<GroupDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: Spacing.spacing300) {
            Text(store.group.name)
                .pretendardCustomFont(textStyle: .headingSmall)
                .foregroundStyle(.gray900)

            Text("모임 상세 화면 (임시)")
                .pretendardCustomFont(textStyle: .bodySmall)
                .foregroundStyle(.gray600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray200)
        .navigationTitle(store.group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
