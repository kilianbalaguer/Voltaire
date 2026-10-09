//
//  AdaptiveLogo.swift
//  Voltaire
//

import SwiftUI

extension View {
    /// Asset logos drawn for light mode — pure black in light mode, pure white in dark mode
    func adaptiveLogo() -> some View {
        modifier(AdaptiveLogoModifier())
    }
}

private struct AdaptiveLogoModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .saturation(0)
            .brightness(colorScheme == .dark ? 1 : -1)
    }
}

struct ConditionalAdaptiveLogo: ViewModifier {
    let icon: String
    @Environment(\.colorScheme) private var colorScheme

    private var shouldAdapt: Bool {
        icon == "LFM" || icon == "Bonsai" || icon == "Voltaire"
    }

    func body(content: Content) -> some View {
        content
            .saturation(shouldAdapt && colorScheme == .dark ? 0 : 1)
            .brightness(shouldAdapt && colorScheme == .dark ? 1 : 0)
    }
}
