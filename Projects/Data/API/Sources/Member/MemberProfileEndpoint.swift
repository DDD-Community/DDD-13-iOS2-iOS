import Alamofire
import Foundations
import Model
import Utill

public enum MemberProfileEndpoint: EndPoint {
    case fetchProfile
    case updateNickname(UpdateNicknameRequestDTO)
    case requestProfileImageUploadURL(ProfileImageUploadURLRequestDTO)
    case updateProfileImage(UpdateProfileImageRequestDTO)

    public var baseURL: String { AppEnvironment.serverBaseURL }

    public var path: String {
        switch self {
        case .fetchProfile: return "/api/v1/members/me"
        case .updateNickname: return "/api/v1/members/me/nickname"
        case .requestProfileImageUploadURL: return "/api/v1/storage/images"
        case .updateProfileImage: return "/api/v1/members/me/profile-image"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchProfile: return .get
        case .requestProfileImageUploadURL: return .post
        case .updateNickname, .updateProfileImage: return .patch
        }
    }

    public var task: APITask {
        switch self {
        case .fetchProfile:
            return .requestPlain

        case let .updateNickname(dto):
            return .requestJSONEncodable(body: dto)

        case let .requestProfileImageUploadURL(dto):
            return .requestJSONEncodable(body: dto)

        case let .updateProfileImage(dto):
            return .requestJSONEncodable(body: dto)
        }
    }
}
