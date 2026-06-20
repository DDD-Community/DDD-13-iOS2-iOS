//
//  GroupDetailTab.swift
//  Presentation
//

public enum GroupDetailTab: Equatable, Sendable {
    case home
    case myPlace(isPlaceVoting: Bool)

    public var label: String {
        switch self {
        case .home: return "홈"
        case let .myPlace(isPlaceVoting): return isPlaceVoting ? "장소보기" : "내 장소보기"
        }
    }
}
