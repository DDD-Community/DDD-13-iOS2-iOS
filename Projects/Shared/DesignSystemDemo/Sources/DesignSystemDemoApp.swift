import SwiftUI
@preconcurrency import KakaoMapsSDK

@main
struct DesignSystemDemoApp: App {
    init() {
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
