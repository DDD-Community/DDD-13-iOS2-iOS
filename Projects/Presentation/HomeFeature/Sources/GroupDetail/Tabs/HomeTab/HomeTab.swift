//
//  HomeTab.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import CoreDependencies
import DesignSystem
import Entity

/// 모임 상세 "홈" 탭.
/// 상단 영역(`HomeTopArea`)부터 멤버 리스트(`MemberList`)까지 전체가 세로 스크롤된다.
struct HomeTab: View {
    @Bindable var store: StoreOf<HomeTabFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HomeTopArea(store: store)

                MemberList(store: store)
                    .padding(.horizontal, Spacing.spacing400)
            }
        }
        .task { store.send(.onAppear) }
        .bottomSheet(
            isPresented: Binding(
                get: { store.isMyDeparturePlaceEditSheetPresented },
                set: { isPresented in
                    guard !isPresented else { return }
                    store.send(.myDeparturePlaceEditSheetDismissed)
                }
            ),
            header: .init(
                title: "출발지 수정",
                onClose: { store.send(.myDeparturePlaceEditSheetDismissed) }
            )
        ) {
            MyDeparturePlaceEditSheetContent(store: store)
        }
        .bottomSheet(
            isPresented: Binding(
                get: { store.isMyAttendanceStatusSheetPresented },
                set: { isPresented in
                    guard !isPresented else { return }
                    store.send(.myAttendanceStatusSheetDismissed)
                }
            )
        ) {
            MyAttendanceStatusEditSheetContent(
                selectedStatus: store.groupDetail?.members.first(where: { $0.isMe })?.attendanceStatus,
                onSelect: { status in
                    store.send(.myAttendanceStatusSelected(status))
                }
            )
        }
        .fullScreenCover(
            item: $store.scope(state: \.destination?.dateVote, action: \.destination.dateVote)
        ) { dateVoteStore in
            DateVoteView(store: dateVoteStore)
        }
    }
}

// MARK: - Preview

#if DEBUG
private extension Entity.Group {
    static func preview(
        name: String,
        dateVoteStatus: GroupDateVoteStatus,
        locationStatus: GroupLocationStatus
    ) -> Entity.Group {
        Entity.Group(
            id: 1,
            meetingId: 1,
            name: name,
            themeTagCode: "FOOD",
            themeTagDisplay: "맛집 탐방",
            listStatus: .inProgress,
            locationStatus: locationStatus,
            dateVoteStatus: dateVoteStatus,
            locationAddress: "서울 강남구 테헤란로 1",
            memberCount: 2,
            members: [
                GroupMember(id: 1, nickname: "나", profileImageUrl: nil, attendanceStatus: .join),
                GroupMember(id: 2, nickname: "팀원", profileImageUrl: nil, attendanceStatus: .join)
            ]
        )
    }
}

private struct HomeTabStatePreview: View {
    private let store: StoreOf<HomeTabFeature>

    init(group: Entity.Group) {
        self.store = Store(initialState: HomeTabFeature.State(group: group)) {
            HomeTabFeature()
        } withDependencies: {
            $0.groupClient = .previewValue
        }
    }

    var body: some View {
        HomeTab(store: store)
    }
}

#Preview("기본 (before/before)") {
    BangawoPreview {
        HomeTabStatePreview(
            group: .preview(name: "강남 모임", dateVoteStatus: .before, locationStatus: .before)
        )
    }
}

#Preview("케이스1 날짜 투표 (inProgress/before)") {
    BangawoPreview {
        HomeTabStatePreview(
            group: .preview(name: "강남 모임", dateVoteStatus: .inProgress, locationStatus: .before)
        )
    }
}

#Preview("케이스2 날짜 확정 (completed/recommended)") {
    BangawoPreview {
        HomeTabStatePreview(
            group: .preview(name: "강남 모임", dateVoteStatus: .completed, locationStatus: .recommended)
        )
    }
}

#Preview("케이스3 장소 투표 (completed/voting)") {
    BangawoPreview {
        HomeTabStatePreview(
            group: .preview(name: "강남 모임", dateVoteStatus: .completed, locationStatus: .voting)
        )
    }
}

#Preview("케이스4 확정 장소 (completed/confirmed)") {
    BangawoPreview {
        HomeTabStatePreview(
            group: .preview(name: "강남 모임", dateVoteStatus: .completed, locationStatus: .confirmed)
        )
    }
}
#endif
