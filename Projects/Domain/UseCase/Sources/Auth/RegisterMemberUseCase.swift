//
//  RegisterMemberUseCase.swift
//  UseCase
//

import Entity

public protocol RegisterMemberUseCase: Sendable {
    func execute(_ member: RegisterMember) async throws -> RegisterMemberResult
}
