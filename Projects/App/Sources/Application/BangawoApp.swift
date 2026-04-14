import SwiftUI
@preconcurrency import KakaoMapsSDK

@main
struct BangawoApp: App {
    init() {
        if let appKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String, !appKey.isEmpty {
            SDKInitializer.InitSDK(appKey: appKey, phase: .real)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
