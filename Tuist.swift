import ProjectDescription

let tuist = Tuist(
  project: .tuist(
    compatibleXcodeVersions: .all,
    swiftVersion: .some("6.0.0"),
    plugins: [
      .local(path: .relativeToRoot("Plugins/ProjectTemplatePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPackagePlugin")),
      .local(path: .relativeToRoot("Plugins/DependencyPlugin")),
    ],
    generationOptions: .options(
      // 🔒 패키지 버전 잠금 비활성화 여부 (기본 false)
      //   true  = Package.resolved 고정 무시(최신으로 다시 풀기)
      //   false = 기존 잠금 유지(권장)
      disablePackageVersionLocking: false,

      // ⚠️ 사이드 이펙트(스크립트 등) 경고를 어떤 타겟에 표시할지
      //   .all / .selected([...]) / .none
      staticSideEffectsWarningTargets: .all,

      // 🆕 4.174.0+: 기본 Swift 버전 자동 생성 옵션
      //   패키지에서 선언한 Swift 버전을 존중하고 자동으로 설정
      defaultSwiftVersion: "6.0.0"

      // 🧰 Xcode 기본 빌드 구성(스킴 선택 기본값)
      // defaultConfiguration: .debug,   // 또는 .release

      // 🔐 인증이 없더라도 명령이 실패하지 않도록 허용(Cloud 기능은 건너뜀)
      // optionalAuthentication: .none,

      // 📊 빌드 인사이트(메트릭 전송) 비활성화
      // buildInsightsDisabled: false,

      // 🧪 SwiftPM 샌드박스 비활성화(특수 환경 외에는 권장하지 않음)
      // disableSandbox: false,

      // 🧯 워크스페이스에 "tuist generate" 스킴 포함(Xcode 내에서 재생성 버튼처럼 사용)
      // includeGenerateScheme: false
    ),
    installOptions: .options()
  )
)
