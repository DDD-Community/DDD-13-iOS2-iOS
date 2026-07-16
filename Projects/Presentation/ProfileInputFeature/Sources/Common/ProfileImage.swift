import Foundation

public enum ProfileImage: Equatable, Sendable {
    case none
    case data(Data, contentType: String)
    case preset(Int)
    case remote(String)
}

public extension ProfileImage {
    var isPresent: Bool {
        switch self {
        case .none: return false
        case .data, .preset, .remote: return true
        }
    }
}
