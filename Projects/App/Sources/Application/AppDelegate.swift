//
//  AppDelegate.swift
//  Bangawo
//
//  Created by Wonji Suh  on 5/29/26.
//

import ComposableArchitecture
@preconcurrency import KakaoMapsSDK
import KakaoSDKAuth
import KakaoSDKCommon
import NidThirdPartyLogin

import CoreDependencies
import Presentation
import Utill

class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let appKey = AppEnvironment.kakaoAppKey
    SDKInitializer.InitSDK(appKey: appKey, phase: .real)
    KakaoSDK.initSDK(appKey: appKey)
    
    prepareDependencies {
      $0.searchStationsClient = SearchStationsFactory.makeClient()
      $0.socialAuthClient = AuthFactory.makeClient()
    }
    
    initializeNaverLoginSDK()
    
    return true
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
  
  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(
    _ application: UIApplication,
    didDiscardSceneSessions sceneSessions: Set<UISceneSession>
  ) {
  }
}
