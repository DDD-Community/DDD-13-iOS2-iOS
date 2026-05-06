import SwiftUI
import ComposableArchitecture
import CoreDependencies
import RootFeature
import Utill
import KakaoSDKCommon
import KakaoSDKAuth
@preconcurrency import KakaoMapsSDK

@main
struct BangawoApp: App {
    private let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    init() {
        let appKey = AppEnvironment.kakaoAppKey
        SDKInitializer.InitSDK(appKey: appKey, phase: .real)
        KakaoSDK.initSDK(appKey: appKey)

        prepareDependencies {
            $0.searchStationsClient = SearchStationsFactory.makeClient()
            $0.socialAuthClient = AuthFactory.makeSocialAuthClient()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
