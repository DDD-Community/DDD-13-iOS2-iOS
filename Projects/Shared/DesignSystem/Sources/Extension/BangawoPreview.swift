//
//  BangawoPreview.swift
//  DesignSystem
//

import SwiftUI

@preconcurrency import KakaoMapsSDK

import Utill

/// #Preview 블록에서 Pretendard 폰트를 등록하고 KakaoMap SDK를 초기화하기 위한 래퍼 뷰.
/// 앱 진입점을 거치지 않는 Preview 환경에서는 폰트 등록·SDK 초기화가 자동으로 일어나지 않으므로
/// init()에서 registerAllCustomFonts()와 KakaoMap SDK 초기화를 호출해 렌더링 전에 보장한다.
public struct BangawoPreview<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        DesignSystemFontFamily.registerAllCustomFonts()
        _ = KakaoMapPreviewInitializer.initialized
        self.content = content()
    }

    public var body: some View {
        content
    }
}

/// KakaoMap SDK는 한 번만 초기화하면 되므로 타입 프로퍼티 lazy 초기화로 1회 호출을 보장한다.
/// (제네릭 타입에는 static stored property를 둘 수 없어 별도 enum 으로 분리한다.)
/// App Key는 Bundle.main(Demo 앱 등) 우선, 없으면 DEBUG 빌드 한정 데모 키로 폴백한다.
private enum KakaoMapPreviewInitializer {
    static let initialized: Void = {
        var appKey = Bundle.main.object(forInfoDictionaryKey: Constant.appKeyInfoPlistKey) as? String ?? ""

        #if DEBUG
        if appKey.isEmpty {
            appKey = Constant.previewDemoAppKey
        }
        #endif

        guard !appKey.isEmpty else {
            Log.error("[BangawoPreview] KAKAO App Key가 비어 있어 KakaoMap SDK를 초기화하지 못했습니다")
            return
        }

        SDKInitializer.InitSDK(appKey: appKey, phase: .real)
    }()
}

private enum Constant {
    static let appKeyInfoPlistKey = "KAKAO_APP_KEY"

    /// Preview 전용 데모 App Key. staticFramework Preview 호스트의 Bundle.main 에는
    /// 키가 없으므로 DEBUG 빌드에 한해 폴백으로 사용한다.
    static let previewDemoAppKey = "24deb407f177fea60f5953321e9c5d29"
}
