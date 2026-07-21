import AuthFlowFeature
import ComposableArchitecture
import HomeFeature
import XCTest

@testable import RootFeature

@MainActor
final class RootFeatureLogoutTests: XCTestCase {
    func testHomeLogoutResetsHomeAndReturnsToFreshLoginFlow() async {
        var initialState = RootFeature.State()
        initialState.mode = .main
        initialState.home.path.append(.profile(ProfileFeature.State()))
        let store = TestStore(initialState: initialState) {
            RootFeature()
        }

        await store.send(.home(.delegate(.loggedOut))) {
            $0.mode = .auth
            $0.auth = AuthFlowFeature.State(entryPoint: .login)
            $0.home = HomeFeature.State()
        }
    }
}
