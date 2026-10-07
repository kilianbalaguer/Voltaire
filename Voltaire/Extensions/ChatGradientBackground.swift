//
//  ChatGradientBackground.swift
//  Voltaire
//

import SwiftUI

/// The app's signature animated background: two drifting radial color blobs
/// over a deep-blue base. Shared by the chat home screen and the splash screen.
struct ChatGradientBackground: View {
    var phase: CGFloat = 0

    var body: some View {
        ZStack {
            // Animated radial blob 1 (cyan)
            RadialGradient(
                colors: [
                    Color(red: 0.133, green: 0.827, blue: 0.933).opacity(0.7),
                    .clear
                ],
                center: UnitPoint(
                    x: 0.8 + 0.15 * sin(phase),
                    y: 0.15 + 0.1 * cos(phase * 0.7)
                ),
                startRadius: 0,
                endRadius: 400
            )

            // Animated radial blob 2 (green)
            RadialGradient(
                colors: [
                    Color(red: 0.290, green: 0.871, blue: 0.502).opacity(0.5),
                    .clear
                ],
                center: UnitPoint(
                    x: 0.7 + 0.1 * cos(phase * 0.8),
                    y: 0.25 + 0.15 * sin(phase * 0.6)
                ),
                startRadius: 0,
                endRadius: 350
            )

            // Static dark blue base
            RadialGradient(
                colors: [
                    Color(red: 0.047, green: 0.290, blue: 0.745).opacity(0.4),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 500
            )
        }
    }
}
