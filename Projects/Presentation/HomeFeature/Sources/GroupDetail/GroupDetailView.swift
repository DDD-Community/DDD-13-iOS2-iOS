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
        ZStack(alignment: .bottom) {
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
            // TODO: 임시로 여기다가 붙여놓음 나중에 상세 지도 뷰 위에 오버레이 시켜주기
            MapBottomSheet(mode: .resizable) {
                NearbyPlaceListSheet(store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList))
            }
        }
        .navigationTitle(store.group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
