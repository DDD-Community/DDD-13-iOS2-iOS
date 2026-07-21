import ComposableArchitecture
import CoreDependencies
import Entity
import XCTest

@testable import HomeFeature

@MainActor
final class ProfileFeatureTests: XCTestCase {
    func testOnAppearLoadsProfileAndDeparturePlaces() async {
        let profile = makeProfile()
        let departures = [makeDeparture(id: 10, isDefault: true)]
        let calls = InvocationRecorder<LoadCall>()
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.memberProfileClient.fetchProfile = {
                await calls.record(.profile)
                return profile
            }
            $0.departurePlaceClient.fetchDeparturePlaces = {
                await calls.record(.departures)
                return departures
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.onAppear) {
            $0.isLoading = true
            $0.errorMessage = nil
        }
        await store.receive { action in
            guard case let .loadResponse(.success(loaded)) = action else { return false }
            return loaded.profile == profile && loaded.departurePlaces == departures
        }

        XCTAssertEqual(store.state.profile, profile)
        XCTAssertEqual(store.state.departurePlaces, departures)
        XCTAssertFalse(store.state.isLoading)
        let recordedCalls = await calls.values
        XCTAssertEqual(Set(recordedCalls), Set([.profile, .departures]))
    }

    func testSelectingDefaultDepartureUpdatesOnlyDefaultFlags() async {
        let first = makeDeparture(id: 10, isDefault: true)
        let second = makeDeparture(id: 20, isDefault: false)
        let updatedSecond = makeDeparture(id: 20, isDefault: true)
        let selectedIDs = InvocationRecorder<Int>()
        var initialState = ProfileFeature.State()
        initialState.profile = makeProfile()
        initialState.departurePlaces = [first, second]
        let store = TestStore(initialState: initialState) {
            ProfileFeature()
        } withDependencies: {
            $0.departurePlaceClient.setDefaultDeparturePlace = { id in
                await selectedIDs.record(id)
                return updatedSecond
            }
        }
        store.exhaustivity = .off(showSkippedAssertions: false)

        await store.send(.defaultDeparturePlaceSelected(20))
        await store.receive { action in
            guard case let .setDefaultDeparturePlaceResponse(.success(departure)) = action else { return false }
            return departure == updatedSecond
        }

        XCTAssertEqual(store.state.departurePlaces.map(\.isDefault), [false, true])
        let ids = await selectedIDs.values
        XCTAssertEqual(ids, [20])
    }

    func testLogoutAlwaysFinishesAndDelegatesLoggedOut() async {
        let logoutCalls = InvocationRecorder<VoidCall>()
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.sessionClient.logout = {
                await logoutCalls.record(.called)
            }
        }

        await store.send(.logoutButtonTapped)
        await store.receive(\.logoutFinished)
        await store.receive { action in
            guard case .delegate(.loggedOut) = action else { return false }
            return true
        }

        let calls = await logoutCalls.values
        XCTAssertEqual(calls, [.called])
    }
}

private extension ProfileFeatureTests {
    func makeProfile() -> MemberProfile {
        MemberProfile(
            id: 1,
            nickname: "방가",
            profileImageURL: "https://example.com/profile.png"
        )
    }

    func makeDeparture(id: Int, isDefault: Bool) -> DeparturePlace {
        DeparturePlace(
            id: id,
            label: id == 10 ? "집" : "회사",
            address: "서울시 강남구",
            roadAddress: "서울시 강남대로",
            placeName: "강남역",
            latitude: 37.0,
            longitude: 127.0,
            isDefault: isDefault
        )
    }
}

private enum LoadCall: Hashable, Sendable {
    case profile
    case departures
}

private enum VoidCall: Equatable, Sendable {
    case called
}

private actor InvocationRecorder<Value: Sendable> {
    private(set) var values: [Value] = []

    func record(_ value: Value) {
        values.append(value)
    }
}
