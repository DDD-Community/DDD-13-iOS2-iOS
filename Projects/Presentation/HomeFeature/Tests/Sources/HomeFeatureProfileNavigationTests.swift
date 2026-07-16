import ComposableArchitecture
import Entity
import ProfileInputFeature
import XCTest

@testable import HomeFeature

@MainActor
final class HomeFeatureProfileNavigationTests: XCTestCase {
    func testMyPageButtonPushesProfile() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        }

        await store.send(.myPageButtonTapped) {
            $0.path.append(.profile(ProfileFeature.State()))
        }
    }

    func testProfileInputCallbackUpdatesProfileAndPopsEditor() async {
        let current = makeProfile(nickname: "방가")
        let updated = makeProfile(nickname: "새이름")
        var profileState = ProfileFeature.State()
        profileState.profile = current
        var initialState = HomeFeature.State()
        initialState.path.append(.profile(profileState))
        let profileID = initialState.path.ids[0]
        initialState.path.append(.profileInput(ProfileInputFeature.State(context: .editing(current))))
        let editorID = initialState.path.ids[1]
        let store = TestStore(initialState: initialState) {
            HomeFeature()
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(
            .path(.element(
                id: editorID,
                action: .profileInput(.delegate(.profileUpdated(updated)))
            ))
        )

        XCTAssertEqual(store.state.path.count, 1)
        guard case let .profile(updatedProfileState) = store.state.path[id: profileID] else {
            return XCTFail("프로필 화면이 스택에 남아 있어야 합니다.")
        }
        XCTAssertEqual(updatedProfileState.profile, updated)
    }

}

private extension HomeFeatureProfileNavigationTests {
    func makeProfile(nickname: String) -> MemberProfile {
        MemberProfile(
            id: 1,
            nickname: nickname,
            profileImageURL: "https://example.com/profile.png"
        )
    }
}
