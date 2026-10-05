//
//  AdaptiveLogo.swift
//  Voltaire
//

import SwiftUI

extension View {
    /// Asset logos drawn for light mode — brighten/desaturate in dark mode
    func adaptiveLogo() -> some View {
        modifier(AdaptiveLogoModifier())
    }
}

private struct AdaptiveLogoModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .brightness(colorScheme == .dark ? 0.7 : 0)
            .saturation(colorScheme == .dark ? 0.35 : 1)
    }
}

struct ConditionalAdaptiveLogo: ViewModifier {
    let icon: String
    @Environment(\.colorScheme) private var colorScheme

    private var shouldAdapt: Bool {
        icon == "LFM" || icon == "Bonsai"
    }

    func body(content: Content) -> some View {
        content
            .brightness(shouldAdapt && colorScheme == .dark ? 0.7 : 0)
            .saturation(shouldAdapt && colorScheme == .dark ? 0.35 : 1)
    }
}
