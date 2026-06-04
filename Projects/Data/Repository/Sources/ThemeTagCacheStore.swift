//
//  ThemeTagCacheStore.swift
//  Repository
//
//  Created by khyeji98 on 2026-06-04.
//

import Entity

/// 모임 목적(테마) 목록을 세션 동안만 보관하는 인메모리 캐시.
/// 앱 실행 시 1회 인스턴스화되는 싱글톤이며, actor 로 동시 접근을 직렬화한다.
actor ThemeTagCacheStore {
    static let shared = ThemeTagCacheStore()

    private var cachedTags: [ThemeTag]?

    private init() {}

    func read() -> [ThemeTag]? {
        cachedTags
    }

    func store(_ tags: [ThemeTag]) {
        cachedTags = tags
    }
}
