import Entity
import Foundation

public struct MemberProfileResponseDTO: Decodable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?

    public func toEntity() -> MemberProfile {
        MemberProfile(
            id: id,
            nickname: nickname,
            profileImageURL: profileImageUrl
        )
    }
}

public struct UpdateNicknameRequestDTO: Encodable, Sendable {
    public let nickname: String

    public init(nickname: String) {
        self.nickname = nickname
    }
}

public struct ProfileImageUploadURLRequestDTO: Encodable, Sendable {
    public let imageType: String
    public let contentType: String

    public init(contentType: String) {
        self.imageType = "PROFILE"
        self.contentType = contentType
    }
}

public struct ProfileImageUploadURLResponseDTO: Decodable, Sendable {
    public let signedUploadUrl: String
    public let objectKey: String
}

public struct UpdateProfileImageRequestDTO: Encodable, Sendable {
    public let objectKey: String

    public init(objectKey: String) {
        self.objectKey = objectKey
    }
}
