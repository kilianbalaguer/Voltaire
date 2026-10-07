//
//  SplashView.swift
//  Voltaire
//

import SwiftUI

/// Launch splash: pulsing logo over the app's animated gradient, then the
/// logo morphs away and the main UI fades in over the same gradient.
struct SplashView: View {
    var onComplete: () -> Void
    /// When embedded over an existing gradient (e.g. onboarding intro),
    /// skip the built-in background so there is exactly one gradient layer.
    var showsBackground = true

    @State private var logoPulsing = false
    @State private var morphingOut = false

    var body: some View {
        ZStack {
            if showsBackground {
                Color(.systemBackground)
                    .ignoresSafeArea()

                // Same shared gradient as everywhere else in the app
                SyncedChatGradientBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }

            VStack(spacing: 16) {
                Image("brain.gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 96, height: 96)
                    .adaptiveLogo()
                    .scaleEffect(logoPulsing && !morphingOut ? 1.08 : 1.0)
                    .opacity(logoPulsing ? 1 : 0.6)
                    .scaleEffect(morphingOut ? 2.2 : 1.0)
                    .opacity(morphingOut ? 0 : 1)
                    .blur(radius: morphingOut ? 12 : 0)

                Text("VOLTAIRE")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .tracking(6)
                    .foregroundStyle(.secondary)
                    .opacity(logoPulsing && !morphingOut ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                logoPulsing = true
            }
            Task {
                try? await Task.sleep(nanoseconds: 1_700_000_000)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    morphingOut = true
                }
                try? await Task.sleep(nanoseconds: 550_000_000)
                onComplete()
            }
        }
    }
}
