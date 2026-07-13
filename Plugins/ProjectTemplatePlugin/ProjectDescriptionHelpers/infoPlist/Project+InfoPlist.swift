//
//  Project+InfoPlist.swift
//  Plugins
//

import Foundation
import ProjectDescription

public extension InfoPlist {
  static let appInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setUILaunchStoryboardName("LaunchScreen")
      .setCFBundleDevelopmentRegion()
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleLocalizations(["ko"])
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundleName("$(PRODUCT_NAME)")
      .setCFBundleDisplayName("$(BUNDLE_DISPLAY_NAME)")  // 🎯 xconfig에서 설정
      .setCFBundleIconName("AppIcon")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setAppTransportSecurity()
      .setCFBundleURLTypes()
      .setLSApplicationQueriesSchemes()
      .setAppUseExemptEncryption(value: false)
      .setCFBundleVersion("$(CURRENT_PROJECT_VERSION)")
      .setLSRequiresIPhoneOS(true)
      .setUIAppFonts(["PretendardVariable.ttf"])
      .setUIBackgroundModes(["remote-notification"])
      .setUIApplicationSceneManifest([
        "UIApplicationSupportsMultipleScenes": true,
        "UISceneConfigurations": [
          "UIWindowSceneSessionRoleApplication": [
            [
              "UISceneConfigurationName": "Default Configuration",
            ]
          ]
        ]
      ])
      .setKakaoAppKey("$(KAKAO_APP_KEY)")
      .setServerBaseURL("$(SERVER_BASE_URL)")
      .setNaverClientID("$(NAVER_CLIENT_ID)")
      .setNaverClientSecret("$(NAVER_CLIENT_SECRET)")
      .setNaverURLScheme("$(NAVER_URL_SCHEME)")
      .setKakaoRestAPIKey("$(KAKAO_REST_API_KEY)")
      .setServerBaseURL("$(SERVER_BASE_URL)")
      .setNSCameraUsageDescription("프로필 사진 촬영을 위해 카메라 접근이 필요합니다")
      .setNSPhotoLibraryUsageDescription("프로필 사진 선택을 위해 사진 접근이 필요합니다")
  )

  static let moduleInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setBaseURL("$(BASE_URL)")
  )
}
