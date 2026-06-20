//
//  SelectPlaceTab.swift
//  HomeFeature
//

/// 장소 투표 후보 담기 화면의 내부 서브탭.
public enum SelectPlaceTab: Equatable, Sendable {
    /// 추천받은 장소를 지도에서 확인하고 후보로 담는 탭.
    case placeMap
    /// 모임원이 담은 후보 장소를 모아 보는 탭.
    case pickedPlace

    public var label: String {
        switch self {
        case .placeMap: return "장소보기"
        case .pickedPlace: return "담은 장소"
        }
    }
}
