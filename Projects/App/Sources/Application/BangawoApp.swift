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
            $0.signupTermsClient = AuthFactory.makeSignupTermsClient()
            $0.nicknameClient = AuthFactory.makeNicknameClient()
            $0.registerMemberClient = AuthFactory.makeRegisterMemberClient()
            $0.groupClient = GroupFactory.makeClient()
        }

        initializeNaverLoginSDK()
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
                .dismissKeyboardOnTap()
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        AuthController.handleOpenUrl(url: url)
                    } else if NidOAuth.shared.handleURL(url) {
                        Log.debug("👤 [Naver] Login callback 처리 완료")
                    }
                }
        }
    }

    private func initializeNaverLoginSDK() {
        let displayName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? ""
        let bundleName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
        let appName = displayName.isEmpty ? bundleName : displayName

        let naverClientID = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String ?? ""
        let naverClientSecret = Bundle.main.infoDictionary?["NAVER_CLIENT_SECRET"] as? String ?? ""
        let naverURLScheme = Bundle.main.infoDictionary?["NAVER_URL_SCHEME"] as? String ?? ""

        guard !appName.isEmpty, !naverClientID.isEmpty, !naverClientSecret.isEmpty, !naverURLScheme.isEmpty else {
                    Log.debug("⚠️ [Naver] Error: Info.plist에서 네이버 로그인 설정값을 찾을 수 없습니다.")
                    return
                }
                NidOAuth.shared.initialize(
                    appName: appName,
                    clientId: naverClientID,
                    clientSecret: naverClientSecret,
                    urlScheme: naverURLScheme
                )
                Log.debug("👤 [Naver] Login SDK 초기화 완료")
        }
}

private extension View {
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}
