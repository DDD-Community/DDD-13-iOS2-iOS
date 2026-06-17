//
//  AttendanceStatus.swift
//  Entity
//

import Foundation

/// 모임 참여 여부 상태.
/// 화면에 노출되는 타입으로, `displayLabel`로 한글 라벨을, `allCases`로 노출 순서(참여-늦참-불참)를 보장합니다.
public enum AttendanceStatus: String, CaseIterable, Equatable, Sendable {
    case join = "JOIN"
    case late = "LATE"
    case absent = "ABSENT"

    public var displayLabel: String {
        switch self {
        case .join: return "참여"
        case .late: return "늦참"
        case .absent: return "불참"
        }
    }
}
