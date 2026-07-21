import ComposableArchitecture

@Reducer
public struct ProfileImagePickerFeature {
    public static let presetCount = 10

    @ObservableState
    public struct State: Equatable {
        public var initialImage: ProfileImage
        public var candidate: ProfileImage

        public init(initialImage: ProfileImage) {
            self.initialImage = initialImage
            self.candidate = initialImage
        }
    }

    public enum Action {
        case presetSelected(index: Int)
        case deleteButtonTapped
        case saveButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismissWithDiscard
            case dismissWithSave(ProfileImage)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .presetSelected(index):
                state.candidate = .preset(index)
                return .none

            case .deleteButtonTapped:
                return .send(.delegate(.dismissWithDiscard))

            case .saveButtonTapped:
                return .send(.delegate(.dismissWithSave(state.candidate)))

            case .delegate:
                return .none
            }
        }
    }
}
