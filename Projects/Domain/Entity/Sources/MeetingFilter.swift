//
//  MeetingFilter.swift
//  Entity
//

public enum MeetingFilter: String, CaseIterable, Equatable, Sendable {
    case all = "전체"
    case inProgress = "진행중"
    case confirmed = "확정"
    case ended = "종료"
}
