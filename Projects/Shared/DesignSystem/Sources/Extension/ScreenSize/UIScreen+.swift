//
//  UIScreen+.swift
//  DDDAttendance
//

import SwiftUI

public extension UIScreen {
  static let screenWidth = UIScreen.main.bounds.size.width
  static let screenHeight = UIScreen.main.bounds.size.height
  static let screenSize = UIScreen.main.bounds.size

  /// 현재 활성 scene keyWindow의 SafeArea inset.
  /// `UIScreen.main`이 iOS 26에서 deprecated이므로 연결된 scene에서 직접 읽는다.
  @MainActor
  static var safeAreaInsets: UIEdgeInsets {
    UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap(\.windows)
      .first(where: \.isKeyWindow)?
      .safeAreaInsets ?? .zero
  }

  @MainActor
  static var safeAreaTop: CGFloat { safeAreaInsets.top }

  @MainActor
  static var safeAreaBottom: CGFloat { safeAreaInsets.bottom }
}
