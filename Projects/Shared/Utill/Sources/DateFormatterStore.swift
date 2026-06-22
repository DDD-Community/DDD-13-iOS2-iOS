//
//  DateFormatterStore.swift
//  Utill
//

import Foundation

/// 자주 쓰이는 DateFormatter 인스턴스를 (포맷·locale·timeZone) 기준으로 캐싱해 재사용하기 위한 저장소
public enum DateFormatterStore {

    // MARK: 편의 접근자

    public static let day = formatter(format: "d")
    public static let weekdayEnglish = formatter(format: "EEE", locale: "en_US")
    public static let full = formatter(format: "M월 d일(E) a h시 m분")

    // MARK: 범용 포맷팅 API

    /// (포맷·locale·timeZone) 조합당 단 한 번만 생성된 DateFormatter를 반환한다.
    public static func formatter(
        format: String,
        locale: String = "ko_KR",
        timeZone: String? = nil
    ) -> DateFormatter {
        let key = Key(format: format, locale: locale, timeZone: timeZone)

        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[key] { return cached }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.dateFormat = format
        if let timeZone { formatter.timeZone = TimeZone(identifier: timeZone) }
        cache[key] = formatter
        return formatter
    }

    /// Date를 주어진 포맷 문자열로 변환한다.
    public static func string(
        from date: Date,
        format: String,
        locale: String = "ko_KR",
        timeZone: String? = nil
    ) -> String {
        formatter(format: format, locale: locale, timeZone: timeZone).string(from: date)
    }

    /// 문자열을 주어진 포맷으로 파싱해 Date로 변환한다. 실패 시 nil.
    public static func date(
        from string: String,
        format: String,
        locale: String = "ko_KR",
        timeZone: String? = nil
    ) -> Date? {
        formatter(format: format, locale: locale, timeZone: timeZone).date(from: string)
    }

    // MARK: 캐시

    private struct Key: Hashable {
        let format: String
        let locale: String
        let timeZone: String?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var cache: [Key: DateFormatter] = [:]
}
