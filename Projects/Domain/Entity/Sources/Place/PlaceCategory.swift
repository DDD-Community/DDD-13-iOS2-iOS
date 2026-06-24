//
//  PlaceCategory.swift
//  Entity
//

import Foundation

/// 장소 카테고리.
/// 필터/표시에 쓰이는 타입으로, `title`로 한글 라벨을, `allCases`로 필터 노출 순서를 보장합니다.
/// 서버가 매칭되지 않는 라벨을 내려주면 `unknown`으로 원본을 보존하며, `allCases`에는 포함되지 않습니다.
public enum PlaceCategory: CaseIterable, Hashable, Sendable {
    case all
    case cafe
    case desert
    case koreaFood
    case japaneseFood
    case snackBar
    case asianFood
    case westernFood
    case buffet
    case bar
    case etc
    case unknown(String)

    public static let allCases: [PlaceCategory] = [
        .all,
        .cafe,
        .desert,
        .koreaFood,
        .japaneseFood,
        .snackBar,
        .asianFood,
        .westernFood,
        .buffet,
        .bar,
        .etc
    ]

    /// 서버 카테고리 라벨(한글)로 카테고리를 생성합니다.
    /// 공백을 제거해 `title`과 비교하고, 매칭되지 않으면 `unknown`으로 원본을 보존합니다.
    public init(categoryLabel: String) {
        let normalizedLabel = categoryLabel.replacingOccurrences(of: " ", with: "")
        let matchedCategory = Self.allCases.first {
            $0.title.replacingOccurrences(of: " ", with: "") == normalizedLabel
        }

        self = matchedCategory ?? .unknown(categoryLabel)
    }

    public var title: String {
        switch self {
        case .all: return "전체"
        case .cafe: return "카페"
        case .desert: return "디저트"
        case .koreaFood: return "한식"
        case .japaneseFood: return "일식"
        case .snackBar: return "분식"
        case .asianFood: return "아시아음식"
        case .westernFood: return "양식"
        case .buffet: return "뷔페"
        case .bar: return "주점"
        case .etc: return "기타"
        case let .unknown(label): return label
        }
    }
}
