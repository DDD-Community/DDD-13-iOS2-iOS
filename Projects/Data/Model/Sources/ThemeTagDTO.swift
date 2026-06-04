//
//  ThemeTagDTO.swift
//  Model
//

import Entity

public struct ThemeTagResponseDTO: Decodable, Sendable {
    public let code: String
    public let displayName: String
}

// MARK: - toEntity

public extension ThemeTagResponseDTO {
    func toEntity() -> ThemeTag {
        ThemeTag(code: code, displayName: displayName)
    }
}
