//
//  OnboardingView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import SwiftUI
import MLXLMCommon

private enum OnboardingPhase {
    case intro, steps, farewell
}

private enum OnboardingStep {
    case welcome, name, install, downloading
}

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @EnvironmentObject var appManager: AppManager
    @State private var phase: OnboardingPhase = .intro
    @State private var step: OnboardingStep = .welcome
    @State private var selectedModel = ModelConfiguration.defaultModel
    @State private var farewellRunning = false

    func beginFarewell() {
        guard phase == .steps, !farewellRunning else { return }
        farewellRunning = true
        appManager.hasSeenOnboarding = true
        withAnimation(.easeInOut(duration: 0.4)) {
            phase = .farewell
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            appManager.splashComplete = true
            showOnboarding = false
        }
    }

    var stepTransition: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.97))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                SyncedChatGradientBackground()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()

                if phase == .intro {
                    SplashView(showsBackground: false) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            phase = .steps
                        }
                    }
                    .transition(.opacity)
            } else if phase == .farewell {
                VStack(spacing: 12) {
                    Text(appManager.userName.isEmpty ? "Welcome" : "Welcome, \(appManager.userName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Your private, on-device AI is ready.")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .opacity
                ))
            } else {
                stepContent
                    .transition(.opacity)
                    .navigationBarTitleDisplayMode(.inline)
                    .tint(.primary)
                    .toolbar {
                        if step == .name || step == .install {
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    step = step == .name ? .welcome : .name
                                } label: {
                                    Image(systemName: "chevron.left")
                                }
                            }
                        }
                        if step == .install {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Skip") {
                                    beginFarewell()
                                }
                            }
                        }
                    }
            }
        }
        }
        .animation(.easeInOut(duration: 0.35), value: phase)
        .animation(.easeInOut(duration: 0.35), value: step)
    }

    @ViewBuilder
    var stepContent: some View {
        switch step {
        case .welcome:
            welcomeStep
                .transition(stepTransition)
        case .name:
            OnboardingNameView(onContinue: { step = .install })
                .transition(stepTransition)
        case .install:
            OnboardingInstallModelView(selectedModel: $selectedModel, onInstall: { step = .downloading })
                .transition(stepTransition)
        case .downloading:
            OnboardingDownloadingModelProgressView(selectedModel: $selectedModel, onDone: beginFarewell)
                .transition(stepTransition)
        }
    }

    var welcomeStep: some View {
        VStack {
            Spacer()

            VStack(spacing: 12) {
                Image("brain.gear")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .adaptiveLogo()

                VStack(spacing: 4) {
                    Text("Voltaire")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Chat with private and local large language models")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 24) {
                Label {
                    VStack(alignment: .leading) {
                        Text("Fast")
                            .font(.headline)
                        Text("Optimized for Apple Silicon")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 8)
                }

                Label {
                    VStack(alignment: .leading) {
                        Text("Private")
                            .font(.headline)
                        Text("Runs locally on your device")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "checkmark.shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 8)
                }

                Label {
                    VStack(alignment: .leading) {
                        Text("Open Source")
                            .font(.headline)
                        Text("View and contribute to the source code")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                } icon: {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    step = .name
                } label: {
                    Text("Get started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .foregroundStyle(.background)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .tint(.primary)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

struct DeviceNotSupportedView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone.gen2.slash")
                .font(.system(size: 64))
                .foregroundStyle(.primary, .tertiary)

            VStack(spacing: 4) {
                Text("Unsupported Device")
                    .font(.title)
                    .fontWeight(.semibold)
                Text("Sorry, Voltaire can only run on devices that support Metal 3.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView(showOnboarding: .constant(true))
}
