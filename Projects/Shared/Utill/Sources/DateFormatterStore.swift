//
//  DateFormatterStore.swift
//  Utill
//

import Foundation

/// 자주 쓰이는 DateFormatter 인스턴스를 캐싱해 재사용하기 위한 저장소
public enum DateFormatterStore {
    public static let day = formatter(locale: "ko_KR", format: "d")
    public static let weekdayEnglish = formatter(locale: "en_US", format: "EEE")
    public static let full = formatter(locale: "ko_KR", format: "M월 d일(E) a h시 m분")

    private static func formatter(locale: String, format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.dateFormat = format
        return formatter
    }
}
