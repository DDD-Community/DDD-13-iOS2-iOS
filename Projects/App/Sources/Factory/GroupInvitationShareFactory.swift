//
//  GroupInvitationShareFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Service

enum GroupInvitationShareFactory {
    static func makeClient() -> GroupInvitationShareClient {
        let service = KakaoShareService()
        let useCase = ShareGroupInvitationUseCaseImpl(kakaoShareService: service)
        return .live(useCase: useCase)
    }
}
