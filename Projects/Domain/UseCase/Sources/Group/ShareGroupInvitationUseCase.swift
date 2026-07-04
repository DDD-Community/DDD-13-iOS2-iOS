//
//  ShareGroupInvitationUseCase.swift
//  UseCase
//

import Entity

public protocol ShareGroupInvitationUseCase: Sendable {
    @MainActor
    func execute(invitation: GroupInvitation) async throws
}
