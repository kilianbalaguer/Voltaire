//
//  GradientClock.swift
//  Voltaire
//

import SwiftUI

/// Single shared clock driving every gradient in the app (splash, onboarding,
/// chat home). Because all instances read the same phase value, morphs between
/// screens never restart or jump the gradient.
@MainActor
@Observable
final class GradientClock {
    static let shared = GradientClock()

    var phase: CGFloat = 0

    private var timer: Timer?
    private var retainCount = 0

    func retain() {
        retainCount += 1
        startTimerIfNeeded()
    }

    func release() {
        retainCount = max(0, retainCount - 1)
        if retainCount == 0 {
            timer?.invalidate()
            timer = nil
        }
    }

    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated {
                self.phase += 1.0 / 30.0
            }
        }
    }
}

/// Gradient background kept in perfect sync across the app. Only this tiny
/// view re-renders on ticks — parents are untouched.
struct SyncedChatGradientBackground: View {
    @State private var clock = GradientClock.shared

    var body: some View {
        ChatGradientBackground(phase: clock.phase)
            .onAppear { clock.retain() }
            .onDisappear { clock.release() }
    }
}
