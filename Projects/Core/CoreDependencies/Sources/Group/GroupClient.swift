//
//  GroupClient.swift
//  CoreDependencies
//

import ComposableArchitecture

import DomainInterface
import Entity
import UseCase

@DependencyClient
public struct GroupClient: Sendable {
    public var fetchGroups: @Sendable () async throws -> [Group]
    public var createGroup: @Sendable (_ name: String, _ themeTagCode: String) async throws -> CreateGroupResult
    public var hostPickMeetingDate: @Sendable (_ meetingId: Int, _ date: String) async throws -> Void
    public var fetchGroupDetail: @Sendable (_ meetingId: Int) async throws -> GroupDetail
    public var updateAttendance: @Sendable (_ groupId: Int, _ attendanceStatus: AttendanceStatus) async throws -> Void
}

public extension GroupClient {
    static func live(
        fetchUseCase: any FetchGroupsUseCase,
        createUseCase: any CreateGroupUseCase,
        hostPickMeetingDateUseCase: any HostPickMeetingDateUseCase,
        fetchDetailUseCase: any FetchGroupDetailUseCase,
        updateAttendanceUseCase: any UpdateAttendanceUseCase
    ) -> Self {
        Self(
            fetchGroups: { try await fetchUseCase.execute() },
            createGroup: { name, themeTagCode in
                try await createUseCase.execute(name: name, themeTagCode: themeTagCode)
            },
            hostPickMeetingDate: { meetingId, date in
                try await hostPickMeetingDateUseCase.execute(meetingId: meetingId, date: date)
            },
            fetchGroupDetail: { meetingId in
                try await fetchDetailUseCase.execute(meetingId: meetingId)
            },
            updateAttendance: { groupId, attendanceStatus in
                try await updateAttendanceUseCase.execute(groupId: groupId, attendanceStatus: attendanceStatus)
            }
        )
    }
}

extension GroupClient: DependencyKey {
    public static var liveValue: GroupClient {
        GroupClient(
            fetchGroups: { throw GroupClientError.notImplemented },
            createGroup: { _, _ in throw GroupClientError.notImplemented },
            hostPickMeetingDate: { _, _ in throw GroupClientError.notImplemented },
            fetchGroupDetail: { _ in throw GroupClientError.notImplemented },
            updateAttendance: { _, _ in throw GroupClientError.notImplemented }
        )
    }

    public static let testValue: GroupClient = GroupClient()

    public static let previewValue: GroupClient = GroupClient(
        fetchGroups: { previewGroups },
        createGroup: { name, themeTagCode in
            CreateGroupResult(groupId: 0, meetingId: 0, name: name, themeTagCode: themeTagCode)
        },
        hostPickMeetingDate: { _, _ in },
        fetchGroupDetail: { _ in previewGroupDetail },
        updateAttendance: { _, _ in }
    )
}

// MARK: - Preview Sample

public extension GroupClient {
    /// 프리뷰/디자인 확인용 샘플 모임. 멤버가 있는 모임과 없는 모임을 함께 제공한다.
    static let previewGroups: [Group] = [
        Group(
            id: 1,
            meetingId: 1,
            name: "주말 등산 모임",
            themeTagCode: "ACTIVITY",
            themeTagDisplay: "함께 땀 흘리며 친해지는 액티비티 모임",
            listStatus: .inProgress,
            locationStatus: .before,
            dateVoteStatus: .before,
            locationAddress: nil,
            memberCount: 3,
            members: [
                GroupMember(id: 1, nickname: "지혜", profileImageUrl: nil, attendanceStatus: .join),
                GroupMember(id: 2, nickname: "민수", profileImageUrl: nil, attendanceStatus: .join),
                GroupMember(id: 3, nickname: "수진", profileImageUrl: nil, attendanceStatus: .pending)
            ]
        ),
        Group(
            id: 2,
            meetingId: 2,
            name: "퇴근 후 독서 클럽",
            themeTagCode: "STUDY",
            themeTagDisplay: "한 달에 한 권, 함께 읽는 독서 모임",
            listStatus: .inProgress,
            locationStatus: .before,
            dateVoteStatus: .before,
            locationAddress: nil,
            memberCount: 0,
            members: []
        )
    ]

    /// 프리뷰/디자인 확인용 샘플 모임 상세. 출발지가 있는 멤버와 없는 멤버를 함께 제공한다.
    static let previewGroupDetail: GroupDetail = GroupDetail(
        id: 1,
        name: "주말 등산 모임",
        themeTagCode: "ACTIVITY",
        themeTagDisplay: "함께 땀 흘리며 친해지는 액티비티 모임",
        locationStatus: .before,
        dateVoteStatus: .before,
        confirmedDate: nil,
        members: [
            GroupDetailMember(
                id: 1,
                nickname: "지혜",
                profileImageUrl: nil,
                isHost: true,
                isMe: true,
                attendanceStatus: .join,
                departurePlaces: [
                    DeparturePlace(
                        id: 1,
                        label: "집",
                        address: "서울 강남구 역삼동",
                        roadAddress: "서울 강남구 테헤란로 123",
                        placeName: "강남역",
                        latitude: 37.4979,
                        longitude: 127.0276,
                        isDefault: true
                    )
                ]
            ),
            GroupDetailMember(
                id: 2,
                nickname: "민수",
                profileImageUrl: nil,
                isHost: false,
                isMe: false,
                attendanceStatus: .late,
                departurePlaces: []
            )
        ]
    )
}

public extension DependencyValues {
    var groupClient: GroupClient {
        get { self[GroupClient.self] }
        set { self[GroupClient.self] = newValue }
    }
}
