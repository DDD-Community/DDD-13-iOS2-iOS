//
//  PlaceVoteParticipationView.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import CoreDependencies
import DesignSystem
import Entity

/// 약속 장소 투표 참여 화면.
/// 전체 화면 카카오맵 위에 NavigationPage 와 MapBottomSheet 가 겹쳐진 구조다.
struct PlaceVoteParticipationView: View {
    @Bindable var store: StoreOf<PlaceVoteParticipationFeature>

    @Environment(\.dismiss) private var dismiss

    /// 후보 좌표로 구성한 지도 핀. `candidates` 변경 시 `.task`에서 재구성한다.
    @State private var pins: [MapPin] = []
    /// travel-burden 결과로 구성한 멤버 출발지 핀. `travelBurden` 변경 시 갱신한다.
    @State private var memberPins: [MapPin] = []
    /// travel-burden 결과로 구성한 멤버별 경로. `travelBurden` 변경 시 갱신한다.
    @State private var memberRoutes: [MapRoute] = []
    /// 후보 좌표들의 bounding box 중심. `candidates` 변경 시 `.task`에서 갱신한다.
    @State private var mapCenter: MapCoordinate = Constant.defaultCenter
    /// 모든 후보 핀이 보이도록 계산한 줌 레벨. `candidates` 변경 시 `.task`에서 갱신한다.
    @State private var mapZoomLevel: Int = Constant.singlePinZoomLevel
    /// row 탭 시 카메라를 포커싱할 후보 좌표.
    @State private var focusedCoordinate: MapCoordinate?
    /// 바텀시트가 화면 하단을 덮는 높이. 핀 포커싱 중심을 위로 보정하는 데 쓴다.
    @State private var sheetCoveredHeight: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            KakaoMap(
                routes: memberRoutes,
                pins: pins + memberPins,
                initialCenter: mapCenter,
                initialZoomLevel: mapZoomLevel,
                focusedCoordinate: focusedCoordinate,
                focusBottomInset: sheetCoveredHeight
            )
            .ignoresSafeArea()

            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24) { dismissCover() }
                ]
            )

            MapBottomSheet(
                detents: [.ratio(0.5), .ratio(0.8)],
                initialDetent: .ratio(0.5)
            ) {
                PlaceVoteSheetContent(
                    store: store,
                    onFocusPlace: { focusedCoordinate = $0 }
                )
            }
            .onVisibleHeightChanged { sheetCoveredHeight = $0 }

            PlaceVoteButtonArea(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
        }
        .task(id: store.candidates) {
            buildPins()
        }
        .task(id: store.travelBurden) {
            buildMemberRoutes()
        }
        .fullScreenCover(
            item: $store.scope(state: \.participants, action: \.participants)
        ) { participantsStore in
            PlaceVoteParticipantsView(
                store: participantsStore,
                onClose: { store.send(.participants(.dismiss)) }
            )
        }
    }

    private func dismissCover() {
        dismiss()
    }

    /// 후보 좌표로 핀·지도 중심·줌 레벨을 한 번에 계산해 `@State`에 캐싱한다.
    @MainActor
    private func buildPins() {
        let coordinates = store.candidates.compactMap { candidate -> MapCoordinate? in
            guard
                let latitude = candidate.latitude,
                let longitude = candidate.longitude
            else { return nil }

            return MapCoordinate(latitude: latitude, longitude: longitude)
        }

        pins = store.candidates.compactMap { candidate in
            guard
                let latitude = candidate.latitude,
                let longitude = candidate.longitude
            else { return nil }

            return MapPinLabel(image: candidate.categoryLabel.pinIcon, title: candidate.name)
                .makePin(
                    id: String(candidate.id),
                    coordinate: MapCoordinate(latitude: latitude, longitude: longitude)
                )
        }
        mapCenter = Self.center(of: coordinates)
        mapZoomLevel = Self.zoomLevel(of: coordinates)
    }

    /// travel-burden 결과로 멤버 출발지 핀과 경로를 구성한다.
    /// 색상은 burdens 순서대로 `RouteDotColor` 를 순환 배정한다.
    @MainActor
    private func buildMemberRoutes() {
        guard let travelBurden = store.travelBurden else {
            memberPins = []
            memberRoutes = []
            return
        }

        let colors = RouteDotColor.allCases
        var pins: [MapPin] = []
        var routes: [MapRoute] = []

        for (index, burden) in travelBurden.burdens.enumerated() {
            let color = colors[index % colors.count]
            let coordinates = burden.path.map {
                MapCoordinate(latitude: $0.latitude, longitude: $0.longitude)
            }
            guard let departure = coordinates.first else { continue }

            routes.append(
                MapRoute(
                    id: "route-\(burden.memberId)",
                    coordinates: coordinates,
                    dotStyle: RouteDotStyle(color: color)
                )
            )
            pins.append(
                MemberRoutePinLabel(
                    avatarType: avatarType(for: burden.memberId),
                    routeColor: color,
                    transferCount: burden.transfers,
                    durationMinutes: burden.seconds / 60
                )
                .makePin(id: "member-\(burden.memberId)", coordinate: departure)
            )
        }

        memberPins = pins
        memberRoutes = routes
    }

    /// memberId 에 해당하는 멤버의 프로필 이미지로 avatar 타입을 결정한다.
    private func avatarType(for memberId: Int) -> Avatar.AvatarType {
        guard
            let member = store.members.first(where: { $0.id == memberId }),
            let urlString = member.profileImageUrl,
            let url = URL(string: urlString)
        else { return .placeholder }

        return .image(url)
    }

    /// 후보 좌표들의 bounding box 중심. 좌표가 없으면 기본 중심을 반환한다.
    private static func center(of coordinates: [MapCoordinate]) -> MapCoordinate {
        guard !coordinates.isEmpty else { return Constant.defaultCenter }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let centerLatitude = ((latitudes.min() ?? 0) + (latitudes.max() ?? 0)) / 2
        let centerLongitude = ((longitudes.min() ?? 0) + (longitudes.max() ?? 0)) / 2

        return MapCoordinate(latitude: centerLatitude, longitude: centerLongitude)
    }

    /// 모든 후보 핀이 보이도록 bounding box span 으로 근사 계산한 줌 레벨.
    private static func zoomLevel(of coordinates: [MapCoordinate]) -> Int {
        guard coordinates.count > 1 else { return Constant.singlePinZoomLevel }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let latitudeSpan = (latitudes.max() ?? 0) - (latitudes.min() ?? 0)
        let longitudeSpan = (longitudes.max() ?? 0) - (longitudes.min() ?? 0)
        let span = max(latitudeSpan, longitudeSpan)

        if span < 0.005 { return 16 }
        if span < 0.01 { return 15 }
        if span < 0.02 { return 14 }
        if span < 0.04 { return 13 }
        if span < 0.08 { return 12 }

        return 11
    }
}

// MARK: - Button Area

struct PlaceVoteButtonArea: View {
    /// 버튼(large minHeight) + 하단 패딩. safeArea 는 별도로 더한다.
    static let height: CGFloat = Spacing.spacing800 + Spacing.spacing200

    let store: StoreOf<PlaceVoteParticipationFeature>

    var body: some View {
        Group {
            switch store.mode {
            case .voting:
                if !store.selectedPlaceIds.isEmpty {
                    ActionButton(
                        buttonLayout: .single(
                            title: "투표하기",
                            isDisabled: store.isSubmitting,
                            action: { store.send(.voteButtonTapped) }
                        )
                    )
                }

            case .voted:
                if store.isHost {
                    ActionButton(
                        buttonLayout: .dual(
                            primaryTitle: "확정하기",
                            primaryAction: { store.send(.confirmButtonTapped) },
                            secondaryTitle: "다시 투표하기",
                            secondaryAction: { store.send(.revoteButtonTapped) },
                            arrangement: .horizontal
                        )
                    )
                } else {
                    ActionButton(
                        buttonLayout: .dual(
                            primaryTitle: "완료",
                            primaryAction: { store.send(.completeButtonTapped) },
                            secondaryTitle: "다시 투표하기",
                            secondaryAction: { store.send(.revoteButtonTapped) },
                            arrangement: .horizontal
                        )
                    )
                }
            }
        }
        .padding(.bottom, Spacing.spacing200)
        .background(Colors.gray00)
        .padding(.bottom, UIScreen.safeAreaBottom)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Constants

private enum Constant {
    /// 후보 좌표가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
    /// 후보가 1개일 때 사용하는 기본 줌 레벨.
    static let singlePinZoomLevel = 16
}

// MARK: - Preview

#if DEBUG
private extension PlaceVote {
    /// 모든 후보의 `isMyVote` 를 false 로 바꿔 voting 모드를 유도한 프리뷰용 변형.
    var withoutMyVote: PlaceVote {
        PlaceVote(
            deadline: deadline,
            sessionStatus: sessionStatus,
            totalParticipants: totalParticipants,
            votedCount: votedCount,
            memberStatuses: memberStatuses,
            candidates: candidates.map { candidate in
                PlaceVoteCandidate(
                    id: candidate.id,
                    name: candidate.name,
                    categoryLabel: candidate.categoryLabel,
                    address: candidate.address,
                    latitude: candidate.latitude,
                    longitude: candidate.longitude,
                    voteCount: candidate.voteCount,
                    isMyVote: false
                )
            }
        )
    }
}

private func makePlaceVoteParticipationStore(
    placeVote: PlaceVote
) -> StoreOf<PlaceVoteParticipationFeature> {
    Store(
        initialState: PlaceVoteParticipationFeature.State(
            meetingId: 1,
            placeVote: placeVote,
            members: GroupClient.previewGroupDetail.members
        )
    ) {
        PlaceVoteParticipationFeature()
    } withDependencies: {
        $0.voteClient = .previewValue
    }
}

#Preview("투표 중") {
    BangawoPreview {
        PlaceVoteParticipationView(
            store: makePlaceVoteParticipationStore(placeVote: VoteClient.previewPlaceVote.withoutMyVote)
        )
    }
}

#Preview("투표 후") {
    BangawoPreview {
        PlaceVoteParticipationView(
            store: makePlaceVoteParticipationStore(placeVote: VoteClient.previewPlaceVote)
        )
    }
}
#endif
