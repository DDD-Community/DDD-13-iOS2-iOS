//
//  PlaceOptionsClientError.swift
//  DomainInterface
//

import Foundation

public enum PlaceOptionsClientError: LocalizedError, Equatable, Sendable {
    case notImplemented

    public var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "PlaceOptionsClient의 live 구현이 주입되지 않았습니다."
        }
    }
}
