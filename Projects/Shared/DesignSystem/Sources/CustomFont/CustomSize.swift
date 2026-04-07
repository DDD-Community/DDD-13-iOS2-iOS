//
//  CustomSize.swift
//  DesignSystem
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation

public enum CustomSizeFont {
  case heading0
  case heading1
  case heading2

  case titleBold
  case titleRegular

  case bodyBold
  case bodyMedium
  case bodyRegular

  case body2Bold
  case body2Medium
  case body2Regular

  case caption

  public var size: CGFloat {
    switch self {
      case .heading0:
        return 28
      case .heading1:
        return 24
      case .heading2:
        return 22
      case .titleBold:
        return 18
      case .titleRegular:
        return 18
      case .bodyBold:
        return 16
      case .bodyMedium:
        return 16
      case .bodyRegular:
        return 16
      case .body2Bold:
        return 14
      case .body2Medium:
        return 14
      case .body2Regular:
        return 14
      case .caption:
        return 12
    }
  }

  public var fontFamily: PretendardFontFamily {
    switch self {
      case .heading0:
        return .SemiBold
      case .heading1:
        return .SemiBold
      case .heading2:
        return .SemiBold
      case .titleBold:
        return .Bold
      case .titleRegular:
        return .Regular
      case .bodyBold:
        return .SemiBold
      case .bodyMedium:
        return .Medium
      case .bodyRegular:
        return .Regular
      case .body2Bold:
        return .SemiBold
      case .body2Medium:
        return .Medium
      case .body2Regular:
        return .Regular
      case .caption:
        return .Regular
    }
  }
}
