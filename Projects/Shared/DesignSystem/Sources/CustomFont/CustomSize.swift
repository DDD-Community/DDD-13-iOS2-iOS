//
//  CustomSize.swift
//  DesignSystem
//
//  Created by DDD-iOS2 on 4/7/26.
//

import CoreGraphics

public enum CustomSizeFont {
    // MARK: - Display
    case displayLarge
    case displayMedium
    case displaySmall

    // MARK: - Heading
    case headingLarge
    case headingMedium
    case headingSmall

    // MARK: - Title
    case titleLarge
    case titleMedium
    case titleMediumEmphasized
    case titleSmall

    // MARK: - Body
    case bodyLarge
    case bodyLargeEmphasized
    case bodyMedium
    case bodyMediumEmphasized
    case bodySmall
    case bodyXSmall

    // MARK: - Label
    case labelLarge
    case labelMedium
    case labelSmall
    case labelSmallEmphasized
    case labelXSmall

    public var size: CGFloat {
        switch self {
        case .displayLarge: return Typography.typographySize1000
        case .displayMedium: return Typography.typographySize900
        case .displaySmall: return Typography.typographySize800
        case .headingLarge: return Typography.typographySize700
        case .headingMedium: return Typography.typographySize600
        case .headingSmall: return Typography.typographySize500
        case .titleLarge: return Typography.typographySize400
        case .titleMedium: return Typography.typographySize300
        case .titleMediumEmphasized: return Typography.typographySize300
        case .titleSmall: return Typography.typographySize200
        case .bodyLarge: return Typography.typographySize300
        case .bodyLargeEmphasized: return Typography.typographySize300
        case .bodyMedium: return Typography.typographySize200
        case .bodyMediumEmphasized: return Typography.typographySize200
        case .bodySmall: return Typography.typographySize100
        case .bodyXSmall: return Typography.typographySize50
        case .labelLarge: return Typography.typographySize300
        case .labelMedium: return Typography.typographySize200
        case .labelSmall: return Typography.typographySize100
        case .labelSmallEmphasized: return Typography.typographySize100
        case .labelXSmall: return Typography.typographySize50
        }
    }

    public var fontFamily: PretendardFontFamily {
        switch self {
        case .displayLarge: return .Bold
        case .displayMedium: return .SemiBold
        case .displaySmall: return .SemiBold
        case .headingLarge: return .SemiBold
        case .headingMedium: return .SemiBold
        case .headingSmall: return .SemiBold
        case .titleLarge: return .SemiBold
        case .titleMedium: return .Medium
        case .titleMediumEmphasized: return .SemiBold
        case .titleSmall: return .Medium
        case .bodyLarge: return .Regular
        case .bodyLargeEmphasized: return .Medium
        case .bodyMedium: return .Medium
        case .bodyMediumEmphasized: return .Medium
        case .bodySmall: return .Regular
        case .bodyXSmall: return .Regular
        case .labelLarge: return .Medium
        case .labelMedium: return .Medium
        case .labelSmall: return .Medium
        case .labelSmallEmphasized: return .SemiBold
        case .labelXSmall: return .SemiBold
        }
    }

    public var lineHeight: CGFloat {
        switch self {
        case .displayLarge: return Typography.typographyLineHeight1000
        case .displayMedium: return Typography.typographyLineHeight900
        case .displaySmall: return Typography.typographyLineHeight800
        case .headingLarge: return Typography.typographyLineHeight700
        case .headingMedium: return Typography.typographyLineHeight600
        case .headingSmall: return Typography.typographyLineHeight500
        case .titleLarge: return Typography.typographyLineHeight400
        case .titleMedium: return Typography.typographyLineHeight300
        case .titleMediumEmphasized: return Typography.typographyLineHeight300
        case .titleSmall: return Typography.typographyLineHeight200
        case .bodyLarge: return Typography.typographyLineHeight300
        case .bodyLargeEmphasized: return Typography.typographyLineHeight300
        case .bodyMedium: return Typography.typographyLineHeight200
        case .bodyMediumEmphasized: return Typography.typographyLineHeight200
        case .bodySmall: return Typography.typographyLineHeight100
        case .bodyXSmall: return Typography.typographyLineHeight50
        case .labelLarge: return Typography.typographyLineHeight300
        case .labelMedium: return Typography.typographyLineHeight200
        case .labelSmall: return Typography.typographyLineHeight100
        case .labelSmallEmphasized: return Typography.typographyLineHeight100
        case .labelXSmall: return Typography.typographyLineHeight50
        }
    }

    public var letterSpacing: CGFloat {
        switch self {
        case .displayLarge, .displayMedium, .displaySmall:
            return Typography.typographyLetterSpacing300
        case .headingLarge, .headingMedium:
            return Typography.typographyLetterSpacing200
        case .headingSmall:
            return Typography.typographyLetterSpacing100
        case .titleLarge:
            return Typography.typographyLetterSpacing200
        case .titleMedium, .titleMediumEmphasized, .titleSmall:
            return Typography.typographyLetterSpacing100
        case .bodyLarge, .bodyLargeEmphasized,
             .bodyMedium, .bodyMediumEmphasized,
             .bodySmall, .bodyXSmall:
            return Typography.typographyLetterSpacing000
        case .labelLarge, .labelMedium,
             .labelSmall, .labelSmallEmphasized, .labelXSmall:
            return Typography.typographyLetterSpacing000
        }
    }
}
