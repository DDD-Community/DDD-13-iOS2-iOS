//
//  Extension+Configuration.swift
//  DependencyPackagePlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

public extension ConfigurationName {
    static let dev = ConfigurationName.configuration(ConfigurationEnvironment.dev.name)
    static let stage = ConfigurationName.configuration(ConfigurationEnvironment.stage.name)
    static let prod = ConfigurationName.configuration(ConfigurationEnvironment.prod.name)
}

public extension Array where Element == Configuration {
    static let `default`: [Configuration] = [
        .debug(name: .dev, xcconfig: .path(.dev)),
        .release(name: .stage, xcconfig: .path(.stage)),
        .release(name: .prod, xcconfig: .path(.prod)),
        .release(name: .release, xcconfig: .path(.release))
    ]
}

public extension ProjectDescription.Path {
    static func path(_ configuration: ConfigurationName) -> Self {
        return .relativeToRoot("Config/\(configuration.rawValue).xcconfig")
    }
}
