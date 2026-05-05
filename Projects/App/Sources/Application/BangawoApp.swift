import SwiftUI
import ComposableArchitecture
import CoreDependencies
import RootFeature
import Utill
@preconcurrency import KakaoMapsSDK

@main
struct BangawoApp: App {
    private let store = Store(initialState: RootFeature.State()) {
        RootFeature()
    }

    init() {
        SDKInitializer.InitSDK(appKey: AppEnvironment.kakaoAppKey, phase: .real)
        prepareDependencies {
            $0.searchStationsClient = SearchStationsFactory.makeClient()
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView(store: store)
        }
    }
}
