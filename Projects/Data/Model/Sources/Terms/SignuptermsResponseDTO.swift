//
//  SignuptermsResponseDTO.swift
//  Model
//

import Entity

public struct SignuptermsResponseDTO: Decodable {
    public let id: Int
    public let type: String
    public let title: String
    public let content: String
    public let required: Bool
}

public extension SignuptermsResponseDTO {
    func toEntity() -> SignupTerm {
        SignupTerm(id: id, type: type, title: title, content: content, isRequired: required)
    }
}
