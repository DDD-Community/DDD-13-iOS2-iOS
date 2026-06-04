//
//  FetchThemeTagsUseCase.swift
//  UseCase
//
//  Created by khyeji98 on 2026-06-04.
//

import Entity

/// 모임 목적(테마) 목록을 조회하는 UseCase.
public protocol FetchThemeTagsUseCase: Sendable {
    func execute() async throws -> [ThemeTag]
}
