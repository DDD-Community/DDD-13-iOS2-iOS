import Foundation

public struct MemberProfile: Equatable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageURL: String?

    public init(
        id: Int,
        nickname: String,
        profileImageURL: String?
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageURL = profileImageURL
    }
}

public struct ProfileImageUpload: Equatable, Sendable {
    public let data: Data
    public let contentType: String

    public init(data: Data, contentType: String) {
        self.data = data
        self.contentType = contentType
    }
}

public struct MemberProfileUpdate: Equatable, Sendable {
    public let nickname: String?
    public let profileImage: ProfileImageUpload?

    public init(
        nickname: String? = nil,
        profileImage: ProfileImageUpload? = nil
    ) {
        self.nickname = nickname
        self.profileImage = profileImage
    }

    public var isEmpty: Bool {
        nickname == nil && profileImage == nil
    }
}
