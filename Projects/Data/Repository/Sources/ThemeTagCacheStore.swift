//
//  ThemeTagCacheStore.swift
//  Repository
//
//  앱 실행 시 1회 인스턴스화되어 세션 동안만 테마 태그 목록을 보관하는 인메모리 캐시.
//  actor 로 동시 접근을 직렬화한다.
//

import Entity

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
