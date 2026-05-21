//
//  SignuptermsResponseDTO.swift
//  Model
//

public struct SignuptermsResponseDTO: Decodable {
    public let id: Int
    public let type: String
    public let title: String
    public let content: String
    public let required: Bool
}
