//
//  AttendanceStatus.swift
//  Entity
//

import Foundation

/// 모임 참여 여부 상태.
/// 화면에 노출되는 타입으로, `displayLabel`로 한글 라벨을, `allCases`로 노출 순서(참여-늦참-불참)를 보장합니다.
/// 서버가 알 수 없는 값을 내려주면 `unknown`으로 보존하며, `allCases`에는 포함되지 않습니다.
public enum AttendanceStatus: CaseIterable, Equatable, Sendable {
    case join
    case late
    case absent
    case unknown(String)

    public static let allCases: [AttendanceStatus] = [.join, .late, .absent]

    public init(rawValue: String) {
        switch rawValue {
        case "JOIN": self = .join
        case "LATE": self = .late
        case "ABSENT": self = .absent
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .join: return "JOIN"
        case .late: return "LATE"
        case .absent: return "ABSENT"
        case let .unknown(value): return value
        }
    }

    public var displayLabel: String {
        switch self {
        case .join: return "참여"
        case .late: return "늦참"
        case .absent: return "불참"
        case .unknown: return "알 수 없음"
        }
    }
}
