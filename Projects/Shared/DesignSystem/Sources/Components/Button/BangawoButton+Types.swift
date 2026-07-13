//
//  BangawoButton+Types.swift
//  DesignSystem
//

extension BangawoButton {
    public enum Variant {
        case weak
        case solid
    }

    public enum Size: Sendable {
        case xsmall
        case small
        case medium
        case large
    }

    public enum WidthType {
        case `default`
        case maxWidth
    }
}
