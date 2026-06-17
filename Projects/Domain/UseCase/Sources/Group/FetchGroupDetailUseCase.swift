//
//  FetchGroupDetailUseCase.swift
//  UseCase
//

import Entity

public protocol FetchGroupDetailUseCase: Sendable {
    func execute(meetingId: Int64) async throws -> GroupDetail
}
