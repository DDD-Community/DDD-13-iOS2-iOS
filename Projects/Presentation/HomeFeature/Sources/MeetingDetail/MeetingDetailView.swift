//
//  MeetingDetailView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct MeetingDetailView: View {
    private let store: StoreOf<MeetingDetailFeature>

    public init(store: StoreOf<MeetingDetailFeature>) {
        self.store = store
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: Spacing.spacing300) {
                Text(store.meeting.title)
                    .pretendardCustomFont(textStyle: .headingSmall)
                    .foregroundStyle(.gray900)

                Text("모임 상세 화면 (임시)")
                    .pretendardCustomFont(textStyle: .bodySmall)
                    .foregroundStyle(.gray600)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray200)
            // TODO: 임시로 여기다가 붙여놓음 나중에 상세 지도 뷰 위에 오버레이 시켜주기
            MapBottomSheet {
                NearbyPlaceListSheet(
                    store: store.scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList)
                )
            }
        }
        .navigationTitle(store.meeting.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
