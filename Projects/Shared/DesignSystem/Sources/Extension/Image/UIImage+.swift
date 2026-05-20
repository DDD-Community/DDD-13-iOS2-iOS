//
//  UIImage+.swift
//  DesignSystem
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
