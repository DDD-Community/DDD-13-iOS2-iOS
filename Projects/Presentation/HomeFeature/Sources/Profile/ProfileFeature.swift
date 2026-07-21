import ComposableArchitecture
import CoreDependencies
import Entity

@Reducer
public struct ProfileFeature {
    @Dependency(\.memberProfileClient) private var memberProfileClient
    @Dependency(\.departurePlaceClient) private var departurePlaceClient
    @Dependency(\.sessionClient) private var sessionClient

    public struct LoadedProfile: Equatable, Sendable {
        public let profile: MemberProfile
        public let departurePlaces: [DeparturePlace]

        public init(profile: MemberProfile, departurePlaces: [DeparturePlace]) {
            self.profile = profile
            self.departurePlaces = departurePlaces
        }
    }

    @ObservableState
    public struct State: Equatable {
        public var profile: MemberProfile?
        public var departurePlaces: [DeparturePlace]
        public var isLoading: Bool
        public var isLoggingOut: Bool
        public var errorMessage: String?
        public var isDeparturePlaceSheetPresented: Bool

        public init(
            profile: MemberProfile? = nil,
            departurePlaces: [DeparturePlace] = [],
            isLoading: Bool = false,
            isLoggingOut: Bool = false,
            errorMessage: String? = nil,
            isDeparturePlaceSheetPresented: Bool = false
        ) {
            self.profile = profile
            self.departurePlaces = departurePlaces
            self.isLoading = isLoading
            self.isLoggingOut = isLoggingOut
            self.errorMessage = errorMessage
            self.isDeparturePlaceSheetPresented = isDeparturePlaceSheetPresented
        }

        public var defaultDeparturePlace: DeparturePlace? {
            departurePlaces.first(where: \.isDefault)
        }
    }

    public enum Action {
        case onAppear
        case retryButtonTapped
        case loadResponse(Result<LoadedProfile, Error>)
        case profileUpdated(MemberProfile)
        case departurePlaceRowTapped
        case departurePlaceSheetDismissed
        case defaultDeparturePlaceSelected(Int)
        case setDefaultDeparturePlaceResponse(Result<DeparturePlace, Error>)
        case addDeparturePlaceTapped
        case editDeparturePlaceTapped(Int)
        case departurePlacesRefreshRequested
        case departurePlacesResponse(Result<[DeparturePlace], Error>)
        case editProfileButtonTapped
        case logoutButtonTapped
        case logoutFinished
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case editProfileRequested(MemberProfile)
            case addDeparturePlaceRequested
            case editDeparturePlaceRequested(Int)
            case loggedOut
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .retryButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                let memberClient = memberProfileClient
                let departureClient = departurePlaceClient
                return .run { send in
                    await send(.loadResponse(Result {
                        async let profile = memberClient.fetchProfile()
                        async let departurePlaces = departureClient.fetchDeparturePlaces()
                        return try await LoadedProfile(
                            profile: profile,
                            departurePlaces: departurePlaces
                        )
                    }))
                }

            case let .loadResponse(.success(loaded)):
                state.isLoading = false
                state.profile = loaded.profile
                state.departurePlaces = loaded.departurePlaces
                return .none

            case .loadResponse(.failure):
                state.isLoading = false
                state.errorMessage = "프로필 정보를 불러오지 못했습니다."
                return .none

            case let .profileUpdated(profile):
                state.profile = profile
                return .none

            case .departurePlaceRowTapped:
                state.isDeparturePlaceSheetPresented = true
                return .none

            case .departurePlaceSheetDismissed:
                state.isDeparturePlaceSheetPresented = false
                return .none

            case let .defaultDeparturePlaceSelected(id):
                let client = departurePlaceClient
                return .run { send in
                    await send(.setDefaultDeparturePlaceResponse(
                        Result { try await client.setDefaultDeparturePlace(id) }
                    ))
                }

            case let .setDefaultDeparturePlaceResponse(.success(selected)):
                state.departurePlaces = state.departurePlaces.map { departurePlace in
                    departurePlace.updating(isDefault: departurePlace.id == selected.id)
                }
                state.isDeparturePlaceSheetPresented = false
                return .none

            case .setDefaultDeparturePlaceResponse(.failure):
                state.errorMessage = "기본 출발지를 변경하지 못했습니다."
                return .none

            case .addDeparturePlaceTapped:
                state.isDeparturePlaceSheetPresented = false
                return .send(.delegate(.addDeparturePlaceRequested))

            case let .editDeparturePlaceTapped(id):
                state.isDeparturePlaceSheetPresented = false
                return .send(.delegate(.editDeparturePlaceRequested(id)))

            case .departurePlacesRefreshRequested:
                let client = departurePlaceClient
                return .run { send in
                    await send(.departurePlacesResponse(
                        Result { try await client.fetchDeparturePlaces() }
                    ))
                }

            case let .departurePlacesResponse(.success(departurePlaces)):
                state.departurePlaces = departurePlaces
                return .none

            case .departurePlacesResponse(.failure):
                state.errorMessage = "출발지 정보를 갱신하지 못했습니다."
                return .none

            case .editProfileButtonTapped:
                guard let profile = state.profile else { return .none }
                return .send(.delegate(.editProfileRequested(profile)))

            case .logoutButtonTapped:
                guard !state.isLoggingOut else { return .none }
                state.isLoggingOut = true
                let client = sessionClient
                return .run { send in
                    await client.logout()
                    await send(.logoutFinished)
                }

            case .logoutFinished:
                state.isLoggingOut = false
                return .send(.delegate(.loggedOut))

            case .delegate:
                return .none
            }
        }
    }
}

private extension DeparturePlace {
    func updating(isDefault: Bool) -> DeparturePlace {
        DeparturePlace(
            id: id,
            label: label,
            address: address,
            roadAddress: roadAddress,
            placeName: placeName,
            latitude: latitude,
            longitude: longitude,
            isDefault: isDefault
        )
    }
}
