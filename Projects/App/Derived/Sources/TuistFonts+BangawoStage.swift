// swiftlint:disable all
// Generated using Tuist (SwiftGen) — https://github.com/tuist/tuist

#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
import CoreText

public enum DesignSystemFontFamily {
  public enum PretendardVariable {
    public static let black: String = "PretendardVariable-Black"
    public static let bold: String = "PretendardVariable-Bold"
    public static let extraBold: String = "PretendardVariable-ExtraBold"
    public static let extraLight: String = "PretendardVariable-ExtraLight"
    public static let light: String = "PretendardVariable-Light"
    public static let medium: String = "PretendardVariable-Medium"
    public static let regular: String = "PretendardVariable-Regular"
    public static let semiBold: String = "PretendardVariable-SemiBold"
    public static let thin: String = "PretendardVariable-Thin"
    public static let all: [String] = [
      "PretendardVariable-Black",      "PretendardVariable-Bold",      "PretendardVariable-ExtraBold",      "PretendardVariable-ExtraLight",      "PretendardVariable-Light",      "PretendardVariable-Medium",      "PretendardVariable-Regular",      "PretendardVariable-SemiBold",      "PretendardVariable-Thin"    ]
  }

  public static func registerAllCustomFonts() {
    let paths: Set<String> = [
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
      "Projects/App/Resources/FontAsset/PretendardVariable.ttf",
    ]
    paths.forEach { registerFont(path: $0) }
  }

  private static func registerFont(path: String) {
    let filename = (path as NSString).lastPathComponent
    let resourceName = (filename as NSString).deletingPathExtension
    let resourceExt = (filename as NSString).pathExtension
    guard let url = Bundle.module.url(forResource: resourceName, withExtension: resourceExt) else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }
}

#if canImport(SwiftUI)
public extension Font {
  static func designSystem(_ name: String, size: CGFloat) -> Font {
    return Font.custom(name, size: size)
  }
}
#endif

#if canImport(UIKit)
public extension UIFont {
  static func designSystem(_ name: String, size: CGFloat) -> UIFont {
    return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
  }
}
#endif
// swiftlint:enable all
