import SwiftUI
import MLXLMCommon
import SwiftData
import Shimmer

struct ResetAppView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    @State private var showSlideButton = false
    @State private var countdown: Double = 5.0
    @State private var countdownTimer: Timer?
    @State private var isResetting = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if showSlideButton {
                slideToResetView
            } else {
                confirmationView
            }
        }
        .navigationTitle("Reset App")
        .navigationBarTitleDisplayMode(.inline)
        .navigationPopGestureDisabled(true)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .onDisappear {
            countdownTimer?.invalidate()
        }
    }

    // MARK: - Confirmation View

    private var confirmationView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.12))
                        .frame(width: 100, height: 100)

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.red)
                }

                VStack(spacing: 8) {
                    Text("Reset everything?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This will permanently delete all models, chats, conversations, and settings. The app will return to its initial state.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }

            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "trash.fill")
                        .foregroundStyle(.red)
                    Text("All downloaded models")
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 10) {
                    Image(systemName: "message.fill")
                        .foregroundStyle(.red)
                    Text("All conversations and chats")
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 10) {
                    Image(systemName: "gearshape.fill")
                        .foregroundStyle(.red)
                    Text("All settings and preferences")
                        .foregroundStyle(.primary)
                }
                HStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundStyle(.red)
                    Text("Onboarding status")
                        .foregroundStyle(.primary)
                }
            }
            .padding(16)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 24)

            Spacer()

            Button {
                startResetFlow()
            } label: {
                Text("Yes, reset everything")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Slide to Reset View

    private var slideToResetView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.12))
                        .frame(width: 100, height: 100)

                    if isResetting {
                        ProgressView()
                            .scaleEffect(1.2)
                    } else {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                    }
                }

                VStack(spacing: 8) {
                    Text(isResetting ? "Resetting app..." : "Swipe to reset")
                        .font(.title3)
                        .fontWeight(.bold)

                    if !isResetting {
                        Text("This action cannot be undone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if !isResetting {
                VStack(spacing: 16) {
                    SlideButton(styling: slideButtonStyling, action: {
                        await performReset()
                    }, label: {
                        if countdown <= 0 {
                            Text("Swipe to reset")
                                .shimmering()
                                .padding(.leading, 20)
                        } else {
                            Text("Swipe to reset")
                                .padding(.leading, 20)
                        }
                    })
                    .disabled(countdown > 0)

                    HStack(spacing: 6) {
                        if countdown > 0 {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("Available in \(Int(countdown))s")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(height: 16)
                    .opacity(countdown > 0 ? 1 : 0)
                    .animation(.easeInOut(duration: 0.3), value: countdown > 0)
                }
                .padding(.horizontal, 24)
            }

            Spacer()
                .frame(height: 40)
        }
    }

    // MARK: - SlideButton Styling

    private var slideButtonStyling: SlideButtonStyling {
        SlideButtonStyling(
            indicatorSize: 60,
            indicatorSpacing: 5,
            indicatorColor: .red,
            backgroundColor: .red.opacity(0.3),
            textColor: .primary,
            indicatorSystemName: "arrow.counterclockwise",
            indicatorDisabledSystemName: "lock",
            textAlignment: .globalCenter,
            textFadesOpacity: true,
            textHiddenBehindIndicator: true,
            textShimmers: false
        )
    }

    // MARK: - Actions

    private func startResetFlow() {
        showSlideButton = true
        countdown = 5.0

        countdownTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            countdown -= 0.1
            if countdown <= 0 {
                countdown = 0
                timer.invalidate()
            }
        }
    }

    private func performReset() async {
        await MainActor.run {
            isResetting = true
        }

        // 1. Stop any running LLM
        llm.loadState = .idle

        // 2. Delete all model files
        deleteAllModelsAndCache()

        // 3. Delete all chats and messages
        do {
            try modelContext.delete(model: Thread.self)
            try modelContext.delete(model: Message.self)
        } catch {
            print("Failed to delete chats:", error)
        }

        // 4. Reset all AppManager settings
        await MainActor.run {
            appManager.installedModels.removeAll()
            appManager.currentModelName = nil
            appManager.hasSeenOnboarding = false
            appManager.systemPrompt = "You are a helpful assistant. You can use Markdown and LaTeX (enclosed in $$) to format your messages, but try not to use Markdown styling in a line that contains a LaTeX formula."
            appManager.showKeyboardOnLaunch = false
        }

        // 5. Restart the app by posting notification and dismissing
        await MainActor.run {
            isResetting = false
            dismiss()
            NotificationCenter.default.post(name: .restartApp, object: nil)
        }
    }
}
