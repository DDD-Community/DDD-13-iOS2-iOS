//
//  GroupFactory.swift
//  Bangawo
//

import CoreDependencies
import DataUseCase
import Repository

enum GroupFactory {
    static func makeClient() -> GroupClient {
        let repository = GroupRepositoryImpl()
        let fetchUseCase = FetchGroupsUseCaseImpl(repository: repository)
        let createUseCase = CreateGroupUseCaseImpl(repository: repository)
        let hostPickMeetingDateUseCase = HostPickMeetingDateUseCaseImpl(repository: repository)
        let fetchDetailUseCase = FetchGroupDetailUseCaseImpl(repository: repository)
        let updateAttendanceUseCase = UpdateAttendanceUseCaseImpl(repository: repository)
        let issueInviteCodeUseCase = IssueInviteCodeUseCaseImpl(repository: repository)
        return .live(
            fetchUseCase: fetchUseCase,
            createUseCase: createUseCase,
            hostPickMeetingDateUseCase: hostPickMeetingDateUseCase,
            fetchDetailUseCase: fetchDetailUseCase,
            updateAttendanceUseCase: updateAttendanceUseCase,
            issueInviteCodeUseCase: issueInviteCodeUseCase
        )
    }
}
