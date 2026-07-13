//
//  ShareGroupInvitationUseCaseImpl.swift
//  DataUseCase
//

import Entity
import Service
import UseCase

public final class ShareGroupInvitationUseCaseImpl: ShareGroupInvitationUseCase {
    private let kakaoShareService: KakaoShareServiceInterface

    public init(kakaoShareService: KakaoShareServiceInterface) {
        self.kakaoShareService = kakaoShareService
    }

    @MainActor
    public func execute(invitation: GroupInvitation) async throws {
        try await kakaoShareService.shareInvitation(invitation)
    }
}
