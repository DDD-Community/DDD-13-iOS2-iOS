//
//  Meeting.swift
//  Entity
//

import Foundation

public struct Meeting: Identifiable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let hashtag: String
    public let status: MeetingFilter
    public let participantCount: Int

    public init(
        id: UUID,
        title: String,
        hashtag: String,
        status: MeetingFilter,
        participantCount: Int
    ) {
        self.id = id
        self.title = title
        self.hashtag = hashtag
        self.status = status
        self.participantCount = participantCount
    }
}
