//
//  ThemeTag.swift
//  Entity
//
//  Created by khyeji98 on 2026-06-04.
//

import Foundation

/// 모임 목적(테마)을 나타내는 도메인 엔티티.
public struct ThemeTag: Equatable, Sendable, Identifiable {
    public let code: String
    public let displayName: String

    public var id: String { code }

    public init(code: String, displayName: String) {
        self.code = code
        self.displayName = displayName
    }
}
