import SwiftUI

@preconcurrency import KakaoMapsSDK

import DesignSystem

@main
struct DesignSystemDemoApp: App {
    init() {
        DesignSystemFontFamily.registerAllCustomFonts()

        if let appKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String, !appKey.isEmpty {
            print("[KakaoMap] App Key loaded: \(appKey.prefix(6))******")
            SDKInitializer.InitSDK(appKey: appKey, phase: .real)
        } else {
            print("[KakaoMap] App Key not found in Info.plist")
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DesignSystemDemoView()
            }
        }
    }
}
