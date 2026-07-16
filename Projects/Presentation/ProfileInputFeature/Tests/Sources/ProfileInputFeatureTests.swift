import ComposableArchitecture
import CoreDependencies
import Entity
import XCTest

@testable import ProfileInputFeature

@MainActor
final class ProfileInputFeatureTests: XCTestCase {
    func testRegistrationKeepsNicknameValidationAndDepartureDelegate() async {
        let nicknameRecorder = InvocationRecorder<String>()
        let store = TestStore(
            initialState: ProfileInputFeature.State(
                context: .registration,
                name: "방가",
                profileImage: .preset(1)
            )
        ) {
            ProfileInputFeature()
        } withDependencies: {
            $0.nicknameClient.validate = { nickname in
                await nicknameRecorder.record(nickname)
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.nextButtonTapped) {
            $0.isNicknameValidating = true
        }
        await store.receive({ action in
            guard case let .nicknameValidateResponse(name, .success) = action else { return false }
            return name == "방가"
        }) {
            $0.isNicknameValidating = false
        }
        await store.receive { action in
            guard case let .delegate(.proceedToDepartureSearch(name)) = action else { return false }
            return name == "방가"
        }

        let nicknames = await nicknameRecorder.values
        XCTAssertEqual(nicknames, ["방가"])
    }

    func testEditingInitializesExistingProfileAndNoChangeCompletesWithoutAPI() async {
        let profile = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/profile.png"
        )
        let calls = InvocationRecorder<ProfileCall>()
        let store = makeEditingStore(profile: profile, calls: calls, fetchedProfile: profile)

        XCTAssertEqual(store.state.name, "방가")
        XCTAssertEqual(store.state.profileImage, .remote("https://example.com/profile.png"))

        await store.send(.nextButtonTapped)
        await store.receive { action in
            guard case let .delegate(.profileUpdated(updatedProfile)) = action else { return false }
            return updatedProfile == profile
        }

        let recordedCalls = await calls.values
        XCTAssertTrue(recordedCalls.isEmpty)
    }

    func testEditingNicknameOnlyValidatesAndUpdatesNicknameThenRefetches() async {
        let current = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/profile.png"
        )
        let updated = MemberProfile(
            id: 1,
            nickname: "새이름",
            profileImageURL: "https://example.com/profile.png"
        )
        let calls = InvocationRecorder<ProfileCall>()
        let nicknameRecorder = InvocationRecorder<String>()
        let store = makeEditingStore(
            profile: current,
            calls: calls,
            fetchedProfile: updated,
            configure: {
                $0.nicknameClient.validate = { nickname in
                    await nicknameRecorder.record(nickname)
                }
            }
        )

        await store.send(.binding(.set(\.name, "새이름"))) {
            $0.name = "새이름"
        }
        await store.send(.nextButtonTapped) {
            $0.isNicknameValidating = true
        }
        await store.receive { action in
            guard case let .nicknameValidateResponse(name, .success) = action else { return false }
            return name == "새이름"
        }
        await store.receive { action in
            guard case let .profileUpdateResponse(.success(profile)) = action else { return false }
            return profile == updated
        }
        await store.receive { action in
            guard case let .delegate(.profileUpdated(profile)) = action else { return false }
            return profile == updated
        }

        let nicknames = await nicknameRecorder.values
        let recordedCalls = await calls.values
        XCTAssertEqual(nicknames, ["새이름"])
        XCTAssertEqual(recordedCalls, [.updateNickname("새이름"), .fetch])
    }

    func testEditingImageOnlyUploadsImageThenRefetches() async {
        let current = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/old.png"
        )
        let updated = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/new.png"
        )
        let imageData = Data([0xFF, 0xD8, 0xFF])
        let calls = InvocationRecorder<ProfileCall>()
        let store = makeEditingStore(profile: current, calls: calls, fetchedProfile: updated)

        await store.send(.avatarMenuAlbumImagePicked(imageData, contentType: "image/jpeg")) {
            $0.profileImage = .data(imageData, contentType: "image/jpeg")
        }
        await store.send(.nextButtonTapped)
        await store.receive { action in
            guard case let .profileUpdateResponse(.success(profile)) = action else { return false }
            return profile == updated
        }
        await store.receive { action in
            guard case let .delegate(.profileUpdated(profile)) = action else { return false }
            return profile == updated
        }

        let recordedCalls = await calls.values
        XCTAssertEqual(
            recordedCalls,
            [
                .updateImage(ProfileImageUpload(data: imageData, contentType: "image/jpeg")),
                .fetch,
            ]
        )
    }

    func testEditingNicknameAndImageUpdatesOnlyChangedFieldsInOrder() async {
        let current = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/old.png"
        )
        let updated = MemberProfile(
            id: 1,
            nickname: "새이름",
            profileImageURL: "https://example.com/new.png"
        )
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])
        let calls = InvocationRecorder<ProfileCall>()
        let store = makeEditingStore(profile: current, calls: calls, fetchedProfile: updated)

        await store.send(.binding(.set(\.name, "새이름"))) {
            $0.name = "새이름"
        }
        await store.send(.avatarMenuAlbumImagePicked(imageData, contentType: "image/png")) {
            $0.profileImage = .data(imageData, contentType: "image/png")
        }
        await store.send(.nextButtonTapped) {
            $0.isNicknameValidating = true
        }
        await store.receive { action in
            guard case .nicknameValidateResponse("새이름", .success) = action else { return false }
            return true
        }
        await store.receive(\.profileUpdateResponse)
        await store.receive { action in
            guard case let .delegate(.profileUpdated(profile)) = action else { return false }
            return profile == updated
        }

        let recordedCalls = await calls.values
        XCTAssertEqual(
            recordedCalls,
            [
                .updateNickname("새이름"),
                .updateImage(ProfileImageUpload(data: imageData, contentType: "image/png")),
                .fetch,
            ]
        )
    }

    func testEditingFailureShowsAlertAndDoesNotComplete() async {
        let current = MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/profile.png"
        )
        let store = TestStore(
            initialState: ProfileInputFeature.State(context: .editing(current))
        ) {
            ProfileInputFeature()
        } withDependencies: {
            $0.nicknameClient.validate = { _ in }
            $0.memberProfileClient.updateNickname = { _ in throw TestFailure.updateFailed }
            $0.memberProfileClient.updateProfileImage = { _ in XCTFail("이미지 수정이 호출되면 안 됩니다.") }
            $0.memberProfileClient.fetchProfile = {
                XCTFail("수정 실패 뒤 프로필을 재조회하면 안 됩니다.")
                return current
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.binding(.set(\.name, "새이름"))) {
            $0.name = "새이름"
        }
        await store.send(.nextButtonTapped) {
            $0.isNicknameValidating = true
        }
        await store.receive { action in
            guard case .profileUpdateResponse(.failure) = action else { return false }
            return true
        }

        XCTAssertNotNil(store.state.alert)
    }
}

private extension ProfileInputFeatureTests {
    func makeEditingStore(
        profile: MemberProfile,
        calls: InvocationRecorder<ProfileCall>,
        fetchedProfile: MemberProfile,
        configure: (inout DependencyValues) -> Void = { _ in }
    ) -> TestStoreOf<ProfileInputFeature> {
        let store = TestStore(initialState: ProfileInputFeature.State(context: .editing(profile))) {
            ProfileInputFeature()
        } withDependencies: {
            $0.nicknameClient.validate = { _ in }
            $0.memberProfileClient.updateNickname = { nickname in
                await calls.record(.updateNickname(nickname))
            }
            $0.memberProfileClient.updateProfileImage = { upload in
                await calls.record(.updateImage(upload))
            }
            $0.memberProfileClient.fetchProfile = {
                await calls.record(.fetch)
                return fetchedProfile
            }
            configure(&$0)
        }
        store.exhaustivity = .off(showSkippedAssertions: false)
        return store
    }
}

private enum ProfileCall: Equatable, Sendable {
    case updateNickname(String)
    case updateImage(ProfileImageUpload)
    case fetch
}

private enum TestFailure: Error {
    case updateFailed
}

private actor InvocationRecorder<Value: Sendable> {
    private(set) var values: [Value] = []

    func record(_ value: Value) {
        values.append(value)
    }
}
