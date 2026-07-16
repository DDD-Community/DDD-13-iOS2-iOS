import Foundation

import API
import DataInterface
import Entity
import Model
import Networking

private enum ProfileImageUploadError: Error {
    case invalidSignedURL
    case invalidResponse
    case uploadFailed(statusCode: Int)
}

public final class MemberProfileRepositoryImpl: MemberProfileRepositoryProtocol {
    public init() {}

    public func fetchProfile() async throws -> MemberProfile {
        let response: MemberProfileResponseDTO = try await NetworkManager.shared.request(
            MemberProfileEndpoint.fetchProfile
        )
        return response.toEntity()
    }

    public func updateNickname(_ nickname: String) async throws {
        try await NetworkManager.shared.requestVoid(
            MemberProfileEndpoint.updateNickname(
                UpdateNicknameRequestDTO(nickname: nickname)
            )
        )
    }

    public func updateProfileImage(_ image: ProfileImageUpload) async throws {
        let uploadInfo: ProfileImageUploadURLResponseDTO = try await NetworkManager.shared.request(
            MemberProfileEndpoint.requestProfileImageUploadURL(
                ProfileImageUploadURLRequestDTO(contentType: image.contentType)
            )
        )

        try await upload(image, to: uploadInfo.signedUploadUrl)

        let _: MemberProfileResponseDTO = try await NetworkManager.shared.request(
            MemberProfileEndpoint.updateProfileImage(
                UpdateProfileImageRequestDTO(objectKey: uploadInfo.objectKey)
            )
        )
    }

    private func upload(_ image: ProfileImageUpload, to urlString: String) async throws {
        guard let url = URL(string: urlString) else {
            throw ProfileImageUploadError.invalidSignedURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(image.contentType, forHTTPHeaderField: "Content-Type")

        let (_, response) = try await URLSession.shared.upload(for: request, from: image.data)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ProfileImageUploadError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ProfileImageUploadError.uploadFailed(statusCode: httpResponse.statusCode)
        }
    }
}
