//
//  SignupTerm.swift
//  Entity
//

public struct SignupTerm: Equatable, Identifiable {
    public let id: Int
    public let type: String
    public let title: String
    public let content: String
    public let isRequired: Bool
    
    public init(id: Int, type: String, title: String, content: String, isRequired: Bool) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.isRequired = isRequired
    }
}
