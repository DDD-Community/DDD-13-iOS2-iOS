//
//  Extension+String.swift
//  MyPlugin
//

import Foundation
import ProjectDescription

extension String {
  public static func appVersion(version: String = "1.0.0") -> String {
    return version
  }
  
  public static func mainBundleID() -> String {
    return Project.Environment.bundlePrefix
  }
  
  public static func appBuildVersion(buildVersion: String = "10") -> String {
    return buildVersion
  }
  
  public static func appBundleID(name: String) -> String {
    return Project.Environment.bundlePrefix+name
  }
  
}
