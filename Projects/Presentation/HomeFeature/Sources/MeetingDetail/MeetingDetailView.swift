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

            MapBottomSheet {
                VStack(spacing: Spacing.spacing200) {
                    Text("hello")
                    Text("hello")
                    Text("hello")
                    Text("hello")
                    Text("hello")
                    Text("hello")
                }
                .padding(.horizontal, Spacing.spacing300)
            }
            .padding(.horizontal, Spacing.spacing300)
        }
        .navigationTitle(store.meeting.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
