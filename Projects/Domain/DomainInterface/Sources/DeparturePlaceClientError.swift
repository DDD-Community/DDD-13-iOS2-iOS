//
//  DeparturePlaceClientError.swift
//  DomainInterface
//

import Foundation

/// 출발지 Client에서 Presentation 계층이 이해할 수 있는 공통 에러 타입입니다.
public enum DeparturePlaceClientError: LocalizedError, Equatable, Sendable {
    /// 아직 live 구현이 주입되지 않은 Client를 호출했을 때 사용하는 임시 에러입니다.
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "DeparturePlaceClient의 live 구현이 주입되지 않았습니다."
        }
    }
}
