//
//  Image+OptionalAsset.swift
//  DesignSystem
//
//  Created by khyeji98 on 2026-06-04.
//

import SwiftUI
import UIKit

public extension Image {
    /// DesignSystem 번들에 주어진 이름의 에셋이 존재할 때만 `Image`를 반환한다.
    /// 존재하지 않으면 `nil`을 반환하므로, 동적으로 만든 에셋 이름을 안전하게 매칭할 수 있다.
    static func assetIfExists(named name: String) -> Image? {
        guard UIImage(named: name, in: .module, compatibleWith: nil) != nil else { return nil }

        return Image(name, bundle: .module)
    }
}
