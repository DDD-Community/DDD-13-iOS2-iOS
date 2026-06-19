//
//  VoteSessionStatus.swift
//  Entity
//

import Foundation

/// 투표 세션의 진행 상태입니다. 서버가 새로운 값을 내려줄 수 있어 `unknown` 폴백을 둡니다.
public enum VoteSessionStatus: Equatable, Sendable {
    case active
    case expired
    case confirmed
    case unknown(String)

    public init(rawValue: String) {
        switch rawValue {
        case "ACTIVE": self = .active
        case "EXPIRED": self = .expired
        case "CONFIRMED": self = .confirmed
        default: self = .unknown(rawValue)
        }
    }
}
