// swiftlint:disable all
// Generated using Tuist (SwiftGen) — https://github.com/tuist/tuist

import Foundation


public enum L10n {
}

public protocol LocalizableParameterCount {}

public struct LocalizableParameterCount0: LocalizableParameterCount {}
public struct LocalizableParameterCount1: LocalizableParameterCount {}
public struct LocalizableParameterCount2: LocalizableParameterCount {}
public struct LocalizableParameterCount3: LocalizableParameterCount {}
public struct LocalizableParameterCount4: LocalizableParameterCount {}
public struct LocalizableParameterCount5: LocalizableParameterCount {}

public struct LocalizableKey<T: LocalizableParameterCount>: Sendable {
    public let key: String
    public init(key: String) { self.key = key }
}

public extension LocalizableKey where T == LocalizableParameterCount0 {
    var value: String {
        return L10n.tr(key)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount1 {
    func value(_ p0: String) -> String {
        return L10n.tr(key, p0)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount2 {
    func value(_ p0: String, _ p1: String) -> String {
        return L10n.tr(key, p0, p1)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount3 {
    func value(_ p0: String, _ p1: String, _ p2: String) -> String {
        return L10n.tr(key, p0, p1, p2)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount4 {
    func value(_ p0: String, _ p1: String, _ p2: String, _ p3: String) -> String {
        return L10n.tr(key, p0, p1, p2, p3)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount5 {
    func value(_ p0: String, _ p1: String, _ p2: String, _ p3: String, _ p4: String) -> String {
        return L10n.tr(key, p0, p1, p2, p3, p4)
    }
}

public extension L10n {
    static func tr(_ key: String, _ args: CVarArg...) -> String {
        let format = NSLocalizedString(key, tableName: "Localizable", bundle: Bundle.module, comment: "")
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

#if canImport(SwiftUI)
import SwiftUI

public extension LocalizableKey where T == LocalizableParameterCount0 {
    var text: Text {
        return Text(.init(stringLiteral: key), tableName: "Localizable", bundle: Bundle.module)
    }
}

public extension LocalizableKey where T == LocalizableParameterCount1 {
    func text(_ p0: String) -> Text {
        return Text.localized(key, params: [p0])
    }
}

public extension LocalizableKey where T == LocalizableParameterCount2 {
    func text(_ p0: String, _ p1: String) -> Text {
        return Text.localized(key, params: [p0, p1])
    }
}

public extension LocalizableKey where T == LocalizableParameterCount3 {
    func text(_ p0: String, _ p1: String, _ p2: String) -> Text {
        return Text.localized(key, params: [p0, p1, p2])
    }
}

public extension LocalizableKey where T == LocalizableParameterCount4 {
    func text(_ p0: String, _ p1: String, _ p2: String, _ p3: String) -> Text {
        return Text.localized(key, params: [p0, p1, p2, p3])
    }
}

public extension LocalizableKey where T == LocalizableParameterCount5 {
    func text(_ p0: String, _ p1: String, _ p2: String, _ p3: String, _ p4: String) -> Text {
        return Text.localized(key, params: [p0, p1, p2, p3, p4])
    }
}

private extension Text {
    static func localized(_ key: String, params: [String]) -> Text {
        let paramterRemovedKey = key.replacingOccurrences(of: "%@", with: "")
        var interpolation = LocalizedStringKey.StringInterpolation(literalCapacity: paramterRemovedKey.count, interpolationCount: params.count)
        interpolation.appendLiteral(paramterRemovedKey)
        params.forEach { interpolation.appendInterpolation($0) }
        return Text(.init(stringInterpolation: interpolation), tableName: "Localizable", bundle: Bundle.module)
    }
}
#endif
// swiftlint:enable all
