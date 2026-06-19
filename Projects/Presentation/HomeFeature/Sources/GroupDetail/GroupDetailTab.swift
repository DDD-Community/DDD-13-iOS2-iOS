//
//  GroupDetailTab.swift
//  Presentation
//

public enum GroupDetailTab: Equatable, Sendable, CaseIterable {
    case home
    case myPlace

    public var label: String {
        switch self {
        case .home: return "홈"
        case .myPlace: return "내 장소보기"
        }
    }
}
