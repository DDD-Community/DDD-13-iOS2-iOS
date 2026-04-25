import SwiftUI
import ComposableArchitecture
import Presentation
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
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
    }

    var body: some Scene {
        WindowGroup {
            LoginView( // 앱 시작점 임의로 로그인 뷰
                store: Store(initialState: LoginFeature.State()) { // store 주입
                    LoginFeature()
                } withDependencies: { // 로그인 뷰에 의존성 주입
                    $0.socialAuthClient = .live
                }
            ).onOpenURL(perform: { url in
                if (AuthApi.isKakaoTalkLoginUrl(url)) { // 카카오 로그인 처리를 정상적으로 완료
                    AuthController.handleOpenUrl(url: url)
                }
            })
        }
    }
}
