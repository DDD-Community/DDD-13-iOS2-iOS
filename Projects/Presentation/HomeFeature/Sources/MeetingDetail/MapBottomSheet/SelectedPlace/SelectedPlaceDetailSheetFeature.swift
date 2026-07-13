//
//  SelectedPlaceDetailSheetFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation
import UIKit
import Utill

@Reducer
public struct SelectedPlaceDetailSheetFeature {
    @ObservableState
    public struct State: Equatable, Sendable {
        public var placeId: Int
        public var name: String
        public var distanceText: String
        public var categoryName: String
        public var closedDayText: String
        public var businessHoursText: String
        public var roadAddress: String
        public var lotAddress: String

        var naverMapSearchQuery: String {
            name
        }

        public init(
            placeId: Int,
            name: String,
            distanceText: String,
            categoryName: String,
            closedDayText: String,
            businessHoursText: String,
            roadAddress: String,
            lotAddress: String
        ) {
            self.placeId = placeId
            self.name = name
            self.distanceText = distanceText
            self.categoryName = categoryName
            self.closedDayText = closedDayText
            self.businessHoursText = businessHoursText
            self.roadAddress = roadAddress
            self.lotAddress = lotAddress
        }

        public static let mock = State(
            placeId: 0,
            name: "서촌김씨",
            distanceText: "18km",
            categoryName: "디저트",
            closedDayText: "월 휴무",
            businessHoursText: "평일 08:00 - 22:00 / 주말 11:11 - 22:22",
            roadAddress: "서울 강남구 테헤란로 123",
            lotAddress: "서울 강남구 역삼동 123-45"
        )
    }

    public enum Action: Equatable {
        case placeFocused(ConfirmedPlace)
        case placeDetailResponse(PlaceDetail)
        case closeButtonTapped
        case naverMapButtonTapped
    }

    @Dependency(\.placeDetailsClient) private var placeDetailsClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .placeFocused(place):
                state = State(
                    placeId: place.placeId,
                    name: place.name,
                    distanceText: Constant.placeholder,
                    categoryName: place.categoryLabel.title,
                    closedDayText: Constant.placeholder,
                    businessHoursText: Constant.placeholder,
                    roadAddress: place.address,
                    lotAddress: Constant.placeholder
                )

                let placeDetailsClient = self.placeDetailsClient
                let placeId = place.placeId
                return .run { send in
                    do {
                        let details = try await placeDetailsClient.fetchPlaceDetails(ids: [placeId])
                        guard let detail = details.first else { return }

                        await send(.placeDetailResponse(detail))
                    } catch {
                        Log.debug("장소 상세 조회 실패: \(error.localizedDescription)")
                    }
                }
                .cancellable(id: CancelID.detail, cancelInFlight: true)

            case let .placeDetailResponse(detail):
                state.categoryName = detail.categoryLabel.title
                state.closedDayText = detail.holiday
                state.businessHoursText = detail.businessHours
                state.roadAddress = detail.roadAddress
                state.lotAddress = detail.address
                return .none

            case .closeButtonTapped:
                return .none

            case .naverMapButtonTapped:
                let query = state.naverMapSearchQuery
                return .run { _ in
                    await NaverMapOpener.openSearch(query: query)
                }
            }
        }
    }
}

// MARK: - Constants

private enum Constant {
    /// `ConfirmedPlace`에 대응 정보가 없는 필드의 표시값.
    static let placeholder = "-"
}

private enum CancelID {
    case detail
}

@MainActor
private enum NaverMapOpener {
    static func openSearch(query: String) {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        let appName = Bundle.main.bundleIdentifier ?? "Bangawo"

        var appComponents = URLComponents()
        appComponents.scheme = "nmap"
        appComponents.host = "search"
        appComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "appname", value: appName)
        ]

        guard let webURL = makeWebSearchURL(query: query) else { return }

        guard let appURL = appComponents.url else {
            open(url: webURL)
            return
        }

        if UIApplication.shared.canOpenURL(appURL) {
            open(url: appURL)
        } else {
            open(url: webURL)
        }
    }

    private static func makeWebSearchURL(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "map.naver.com"
        components.path = "/p/search/\(query)"
        return components.url ?? URL(string: "https://map.naver.com")
    }

    private static func open(url: URL) {
        UIApplication.shared.open(url)
    }
}
