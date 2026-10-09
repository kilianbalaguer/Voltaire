//
//  Haptic++.swift
//  PsychicPaper
//
//  Created by Kilian Balaguer on 10/7/26.
//

import Foundation
#if os(iOS)
import UIKit

/// Wrapper around UIKit haptics
@MainActor class Haptic {
    static let shared = Haptic()
    private init() { }
    /// Play haptic feedback
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: intensity)
    }
    
    /// Provide haptic user feedback for an action
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
    
    /// Play feedback for a selection
    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
#endif

