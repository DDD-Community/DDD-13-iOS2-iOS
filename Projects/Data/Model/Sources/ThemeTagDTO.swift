//
//  ThemeTagDTO.swift
//  Model
//
//  Created by khyeji98 on 2026-06-04.
//

import Entity

/// 모임 목적(테마) API 응답 DTO.
public struct ThemeTagResponseDTO: Decodable, Sendable {
    public let code: String
    public let displayName: String
}

// MARK: - toEntity

public extension ThemeTagResponseDTO {
    /// DTO 를 모임 목적(테마) 도메인 엔티티로 변환한다.
    func toEntity() -> ThemeTag {
        ThemeTag(code: code, displayName: displayName)
    }
}
