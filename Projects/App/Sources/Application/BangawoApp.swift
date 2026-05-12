import SwiftUI
import ComposableArchitecture
import CoreDependencies
import Presentation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import NidThirdPartyLogin
import Utill

@preconcurrency import KakaoMapsSDK


@main
struct BangawoApp: App {
    init() {
        if let appKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as? String, !appKey.isEmpty {
            SDKInitializer.InitSDK(appKey: appKey, phase: .real) // 카카오 지도 SDK 초기화

            KakaoSDK.initSDK(appKey: appKey)// 카카오 로그인/공유 SDK 초기화
            Log.debug("👤 [Kakao] Login SDK 초기화 완료")
        } else {
            Log.debug("⚠️ [Kakao] Error: Info.plist에서 'KAKAO_APP_KEY'를 찾을 수 없거나 비어 있습니다.")
        }

        initializeNaverLoginSDK()
    }

    var body: some Scene {
        WindowGroup {
            LoginView( // 앱 시작점 임의로 로그인 뷰
                store: Store(initialState: LoginFeature.State()) { // store 주입
                    LoginFeature()
                } withDependencies: {
                    $0.socialAuthClient = AuthFactory.makeSocialAuthClient()
                }
            ).onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) { // 카카오 로그인 처리를 정상적으로 완료
                    AuthController.handleOpenUrl(url: url)
                } else if NidOAuth.shared.handleURL(url) {
                    Log.debug("👤 [Naver] Login callback 처리 완료")
                }
            })
        }
    }

    private func initializeNaverLoginSDK() {
        let displayName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ?? ""
        let bundleName = (Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String) ?? ""
        let appName = displayName.isEmpty ? bundleName : displayName

        let naverClientID = Bundle.main.infoDictionary?["NAVER_CLIENT_ID"] as? String ?? ""
        let naverClientSecret = Bundle.main.infoDictionary?["NAVER_CLIENT_SECRET"] as? String ?? ""
        let naverURLScheme = Bundle.main.infoDictionary?["NAVER_URL_SCHEME"] as? String ?? ""

        if !appName.isEmpty, !naverClientID.isEmpty, !naverClientSecret.isEmpty, !naverURLScheme.isEmpty {
            NidOAuth.shared.initialize(
                appName: appName,
                clientId: naverClientID,
                clientSecret: naverClientSecret,
                urlScheme: naverURLScheme
            )
            Log.debug("👤 [Naver] Login SDK 초기화 완료")
        } else {
            Log.debug("⚠️ [Naver] Error: Info.plist에서 네이버 로그인 설정값을 찾을 수 없습니다.")
        }
    }
}
