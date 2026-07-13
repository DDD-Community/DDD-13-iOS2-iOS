//
//  PlaceCategory+Icon.swift
//  HomeFeature
//

import SwiftUI

import DesignSystem
import Entity

extension PlaceCategory {
    /// 지도 핀 / 카테고리 썸네일에 사용하는 카테고리별 아이콘.
    /// (Entity 가 DesignSystem 을 의존할 수 없어 Presentation 에 둔다.)
    /// 매칭되지 않는 카테고리(`unknown`)는 기본 핀 아이콘으로 폴백한다.
    var pinIcon: Image {
        switch self {
        case .cafe: return Image(assetName: "ic_map_pin_cafe")
        case .desert: return Image(assetName: "ic_map_pin_dessert")
        case .buffet: return Image(assetName: "ic_map_pin_buffet")
        case .bar: return Image(assetName: "ic_map_pin_pub")
        case .koreaFood, .japaneseFood, .snackBar, .asianFood, .westernFood, .all, .etc:
            return Image(assetName: "ic_map_pin_restaurant")
        case .unknown: return Image.Asset.icPin24
        }
    }
}
