import SwiftUI
import SlideButton
import MLXLMCommon

struct DeleteAllModelsView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @Environment(\.dismiss) var dismiss

    @State private var showSlideButton = false
    @State private var countdown: Double = 5.0
    @State private var countdownTimer: Timer?
    @State private var isDeleting = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            if showSlideButton {
                slideToDeleteView
            } else {
                confirmationView
            }
        }
        .navigationTitle("Delete All Models")
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
                    Text("Are you sure?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("This will permanently delete all downloaded models from your device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }

            Spacer()

            installedModelsCard

            Spacer()

            Button {
                startDeleteFlow()
            } label: {
                Text("Yes, delete all models")
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

    // MARK: - Installed Models Card

    private var installedModelsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundStyle(.blue)
                Text("Downloaded Models")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(appManager.installedModels.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.blue)
                    .clipShape(.capsule)
            }

            if appManager.installedModels.isEmpty {
                Text("No models installed")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 4)
            } else {
                ForEach(appManager.installedModels, id: \.self) { model in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.red.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Text(appManager.modelDisplayName(model))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(16)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }

    // MARK: - Slide to Delete View

    private var slideToDeleteView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.12))
                        .frame(width: 100, height: 100)

                    if isDeleting {
                        ProgressView()
                            .scaleEffect(1.2)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                    }
                }

                VStack(spacing: 8) {
                    Text(isDeleting ? "Deleting models..." : "Swipe to delete")
                        .font(.title3)
                        .fontWeight(.bold)

                    if !isDeleting {
                        Text("This action cannot be undone")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if !isDeleting {
                VStack(spacing: 16) {
                    SlideButton(styling: slideButtonStyling, action: {
                        await performDelete()
                    }, label: {
                        Text("Swipe to delete")
                    })
                    .disabled(countdown > 0)

                    if countdown > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                            Text("Available in \(Int(countdown))s")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
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
            textColor: .white,
            indicatorSystemName: "trash",
            indicatorDisabledSystemName: "xmark",
            textAlignment: .center,
            textFadesOpacity: true,
            textHiddenBehindIndicator: true,
            textShimmers: false
        )
    }

    // MARK: - Actions

    private func startDeleteFlow() {
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

    private func performDelete() async {
        await MainActor.run {
            isDeleting = true
        }

        llm.loadState = .idle

        deleteAllModelsAndCache()

        await MainActor.run {
            appManager.installedModels.removeAll()
            appManager.currentModelName = nil
            isDeleting = false
            dismiss()
        }
    }
}
