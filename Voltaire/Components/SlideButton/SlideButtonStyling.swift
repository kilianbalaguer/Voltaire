import SwiftUI

public struct SlideButtonStyling {
    public init(
        indicatorSize: CGFloat = 60,
        indicatorSpacing: CGFloat = 5,
        indicatorColor: Color = .accentColor,
        indicatorShape: ShapeType = .circular,
        indicatorRotatesForRTL: Bool = true,
        indicatorBrightness: Double = 0.0,
        backgroundColor: Color? = nil,
        textColor: Color = .secondary,
        indicatorSystemName: String = "chevron.right",
        indicatorDisabledSystemName: String = "xmark",
        textAlignment: SlideTextAlignment = .center,
        textFadesOpacity: Bool = true,
        textHiddenBehindIndicator: Bool = true,
        textShimmers: Bool = false
    ) {
        self.indicatorSize = indicatorSize
        self.indicatorSpacing = indicatorSpacing
        self.indicatorShape = indicatorShape
        self.indicatorBrightness = indicatorBrightness
        self.indicatorRotatesForRTL = indicatorRotatesForRTL
        self.indicatorColor = indicatorColor
        self.backgroundColor = backgroundColor ?? indicatorColor.opacity(0.3)
        self.textColor = textColor
        self.indicatorSystemName = indicatorSystemName
        self.indicatorDisabledSystemName = indicatorDisabledSystemName
        self.textAlignment = textAlignment
        self.textFadesOpacity = textFadesOpacity
        self.textHiddenBehindIndicator = textHiddenBehindIndicator
        self.textShimmers = textShimmers
    }

    var indicatorSize: CGFloat
    var indicatorSpacing: CGFloat
    var indicatorShape: ShapeType
    var indicatorRotatesForRTL: Bool
    var indicatorBrightness: Double
    var indicatorColor: Color
    var backgroundColor: Color
    var textColor: Color
    var indicatorSystemName: String
    var indicatorDisabledSystemName: String
    var textAlignment: SlideTextAlignment
    var textFadesOpacity: Bool
    var textHiddenBehindIndicator: Bool
    var textShimmers: Bool

    public static let `default`: Self = .init()
}

public enum ShapeType {
    case circular, rectangular(cornerRadius: Double? = 0)
}

public enum SlideTextAlignment {
    case leading
    case globalCenter
    case center
    case trailing

    var horizontalAlignment: HorizontalAlignment {
        switch self {
        case .leading: return .leading
        case .center, .globalCenter: return .center
        case .trailing: return .trailing
        }
    }

    var textAlignment: TextAlignment {
        switch self {
        case .leading: return .leading
        case .center, .globalCenter: return .center
        case .trailing: return .trailing
        }
    }
}
