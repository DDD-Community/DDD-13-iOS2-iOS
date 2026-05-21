//
//  TextInput+Types.swift
//  DesignSystem
//

public enum TextInputType {
    case textfield
    case datefield
    case timefield
}

public enum TextInputState: Equatable {
    case `default`
    case focused
    case typing
    case typed
    case readOnly
    case disabled
    case error
}
