//
//  UIImage+.swift
//  DesignSystem
//
//  Created by DDD-iOS2 on 4/7/26.
//

import SwiftUI

public extension UIImage {
  convenience init?(assetName: String) {
    self.init(named: assetName, in: Bundle.module, with: nil)
  }
}

public extension Image {
  init(assetName: String) {
    if let uiImage = UIImage(assetName: assetName) {
      self.init(uiImage: uiImage)
    } else {
      self = Image(systemName: "questionmark")
    }
  }
}
