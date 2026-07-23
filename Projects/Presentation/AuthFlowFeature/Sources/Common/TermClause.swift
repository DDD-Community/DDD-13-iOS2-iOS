//
//  TermClause.swift
//  Presentation
//
//  약관 동의 항목 정의. 추후 서버/URL 교체에 대비해 데이터로 관리
//

import Foundation

public struct TermClause: Equatable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let urlString: String
    public let isRequired: Bool

    public init(id: Int, title: String, urlString: String, isRequired: Bool = true) {
        self.id = id
        self.title = title
        self.urlString = urlString
        self.isRequired = isRequired
    }

    public var displayTitle: String {
        // 서버에서는 isRequired로 필수, 선택 구분
        // title은 단순 제목만 넘겨줌
        return isRequired ? "(필수) \(title)" : "(선택) \(title)"

    }

    public var url: URL? {
        URL(string: urlString)
    }
}

public extension TermClause {
    // 실제 약관 본문 API 확정 전까지 사용하는 임시 고정 항목
    static let temporaryClauses: [TermClause] = [
        TermClause(
            id: 1,
            title: "개인정보처리방침",
            urlString: "https://lightning-weight-c0c.notion.site/3a619ccc6d3a80089f59dcb19af2b673?source=copy_link",
            isRequired: true
        ),
        TermClause(
            id: 2,
            title: "이용약관",
            urlString: "https://lightning-weight-c0c.notion.site/3a619ccc6d3a80d6af97f6503a959b1b?source=copy_link",
            isRequired: true
        ),
        TermClause(
            id: 3,
            title: "마케팅 정보 수신 동의",
            urlString: "https://lightning-weight-c0c.notion.site/3a619ccc6d3a80f0b334dde67ec0e5b0?source=copy_link",
            isRequired: false
        )
    ]
}
