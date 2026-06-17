//
//  GroupDetailTab.swift
//  Presentation
//

public enum GroupDetailTab: Equatable, Sendable {
    case home
    case vote
    case myPlace

    public var label: String {
        switch self {
        case .home: return "홈"
        case .vote: return "투표"
        case .myPlace: return "내 장소보기"
        }
    }
}
