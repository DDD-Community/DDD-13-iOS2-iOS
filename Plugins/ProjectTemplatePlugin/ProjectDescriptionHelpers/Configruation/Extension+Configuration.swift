//
//  Extension+Configuration.swift
//  DependencyPackagePlugin
//

import Foundation
import ProjectDescription

public extension ConfigurationName {
    static let prod = ConfigurationName.configuration(ConfigurationEnvironment.prod.name)
}

public extension Array where Element == Configuration {
    static let `default`: [Configuration] = [
        .debug(name: .debug, xcconfig: .path(.debug)),
        .release(name: .prod, xcconfig: .path(.prod)),
        .release(name: .release, xcconfig: .path(.release))
    ]
}

public extension ProjectDescription.Path {
    static func path(_ configuration: ConfigurationName) -> Self {
        return .relativeToRoot("Config/\(configuration.rawValue).xcconfig")
    }
}
