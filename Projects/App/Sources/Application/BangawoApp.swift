import SwiftUI

import ComposableArchitecture
@preconcurrency import KakaoMapsSDK
import KakaoSDKAuth
import KakaoSDKCommon
import NidThirdPartyLogin

import CoreDependencies
import Presentation
import Utill

@main
struct BangawoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    init() {}

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        AuthController.handleOpenUrl(url: url)
                    } else if NidOAuth.shared.handleURL(url) {
                        Log.debug("👤 [Naver] Login callback 처리 완료")
                    }
                }
        }
    }

}
