import ProjectDescription
import DependencyPlugin
import ProjectTemplatePlugin
import DependencyPackagePlugin

let project = Project.makeAppModule(
  name: Project.Environment.appName,
  bundleId: .mainBundleID(),
  product: .app,
  settings: .appMainSetting,
  scripts: [],
  dependencies: [
    .Presentation(implements: .Presentation),
    .project(target: "CoreDependencies", path: .relativeToRoot("Projects/Core/Dependencies")),
    .project(target: "DataUseCase", path: .relativeToRoot("Projects/Data/UseCase")),
    .Data(implements: .Repository),
    .Data(implements: .Service),
    .SPM.kakaoMapsSDK,
    .SPM.kakaoSDKCommon,
    .SPM.kakaoSDKAuth,
    .SPM.kakaoSDKUser,
    .SPM.nidThirdPartyLogin
  ],
  sources: ["Sources/**"],
  resources: ["Resources/**"],
  infoPlist: .appInfoPlist,
  schemes: [
    // 테스트 플랜 스킴: 커스텀 구성명 사용 (.dev / .stage / .prod 중 택1)
    Scheme.makeTestPlanScheme(target: .dev, name: Project.Environment.appName),

  ]
)
