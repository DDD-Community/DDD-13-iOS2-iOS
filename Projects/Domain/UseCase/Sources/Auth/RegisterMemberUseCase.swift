//
//  RegisterMemberUseCase.swift
//  UseCase
//

import Entity

public protocol RegisterMemberUseCase: Sendable {
    func execute(nickname: String, agreedTermsIds: [Int], departureLabel: String, departureAddress: String, latitude: Double, longitude: Double) async throws -> RegisterMemberResult
}
