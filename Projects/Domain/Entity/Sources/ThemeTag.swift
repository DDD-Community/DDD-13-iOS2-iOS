//
//  ThemeTag.swift
//  Entity
//
//  모임 목적(테마) 도메인 엔티티. 서버 theme-tags 마스터 데이터로부터 매핑된다.
//

import Foundation

public struct ThemeTag: Equatable, Sendable, Identifiable {
    public let code: String
    public let displayName: String

    public var id: String { code }

    public init(code: String, displayName: String) {
        self.code = code
        self.displayName = displayName
    }
}
