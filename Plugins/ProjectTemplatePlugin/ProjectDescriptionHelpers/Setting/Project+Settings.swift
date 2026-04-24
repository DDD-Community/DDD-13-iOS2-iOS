//
//  Project+Settings.swift
//  MyPlugin
//
//  Created by DDD-iOS2 on 4/7/26.
//

import Foundation
import ProjectDescription

extension Settings {
  private static func commonSettings(
    appName: String,
    displayName: String,
    provisioningProfile: String,
    setSkipInstall: Bool
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setCFBundleDisplayName(displayName)
      .setOtherLdFlags("-ObjC -all_load")
      .setDebugInformationFormat("dwarf-with-dsym")
      .setProvisioningProfileSpecifier(provisioningProfile)
      .setSkipInstall(setSkipInstall)
      .setCFBundleDevelopmentRegion("ko")
  }

  private static func commonBaseSettings(
    appName: String
  ) -> SettingsDictionary {
    return SettingsDictionary()
      .setProductName(appName)
      .setOtherLdFlags("-ObjC -all_load")
      .setStripStyle()
  }

  public static let appMainSetting: Settings = .settings(
    base: SettingsDictionary()
      .setProductName(Project.Environment.appName)
      .setCFBundleDisplayName(Project.Environment.appName)
      .setMarketingVersion(.appVersion())
      .setEnableBackgroundModes()
      .setArchs()
      .setOtherLdFlags()
      .setCurrentProjectVersion(.appBuildVersion())
      .setCodeSignIdentity()
      .setCodeSignStyle()
      .setSwiftVersion("6.0")
      .setVersioningSystem()
      .setProvisioningProfileSpecifier("match Development \(Project.Environment.bundlePrefix)")
      .setDevelopmentTeam(Project.Environment.organizationTeamId)
      .setCFBundleDevelopmentRegion()
      .setDebugInformationFormat(),
    configurations: [
      .debug(
        name: .debug,
        settings:
          commonSettings(
            appName: Project.Environment.appName,
            displayName: Project.Environment.appName,
            provisioningProfile: "match Development \(Project.Environment.bundlePrefix)",
            setSkipInstall: false
          ),
        xcconfig: .path(.dev)
      ),
      .release(
        name: .stage,
        settings:
          commonSettings(
            appName: Project.Environment.appStageName,
            displayName: Project.Environment.appName,
            provisioningProfile: "match AppStore \(Project.Environment.bundlePrefix)",
            setSkipInstall: false
          ),
        xcconfig: .path(.stage)
      ),
      .release(
        name: .release,
        settings:
          commonSettings(
            appName: Project.Environment.appName,
            displayName: Project.Environment.appName,
            provisioningProfile: "match AppStore \(Project.Environment.bundlePrefix)",
            setSkipInstall: false
          ),
        xcconfig: .path(.release)
      ),
      .release(
        name: .prod,
        settings:
          commonSettings(
            appName: Project.Environment.appProdName,
            displayName: Project.Environment.appName,
            provisioningProfile: "match AppStore \(Project.Environment.bundlePrefix)",
            setSkipInstall: false
          ),
        xcconfig: .path(.prod)
      ),

    ], defaultSettings: .recommended
  )

  public static func appBaseSetting(appName: String) -> Settings {
    let appBaseSetting: Settings = .settings(
      base: SettingsDictionary()
        .setProductName(appName)
        .setMarketingVersion(.appVersion())
        .setCurrentProjectVersion(.appBuildVersion())
        .setCodeSignIdentity()
        .setArchs()
        .setSwiftVersion("6.0")
        .setVersioningSystem()
        .setDebugInformationFormat(),
      configurations: [
        .debug(
          name: .debug,
          settings:
            commonBaseSettings(
              appName: appName
            ),
          xcconfig:
              .relativeToRoot("./Config/Dev.xcconfig")
        ),
        .release(
          name: .release,
          settings: commonBaseSettings(
            appName: appName
          ),
          xcconfig: .relativeToRoot("./Config/Release.xcconfig")
        )
      ], defaultSettings: .recommended)

    return appBaseSetting

  }
}
