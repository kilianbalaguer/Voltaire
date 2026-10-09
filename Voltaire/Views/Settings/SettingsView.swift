//
//  SettingsView.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @Environment(\.modelContext) private var modelContext
    @Binding var currentThread: Thread?
    var onDismiss: (() -> Void)? = nil
    @State private var showResetApp = false
    @State private var showDeleteChatsAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("App") {
                    NavigationLink(destination: ModelsSettingsView()) {
                        Label("Manage models", systemImage: "cube")
                    }

                    NavigationLink(destination: ChatsSettingsView()) {
                        Label("Personalization", systemImage: "person")
                    }

                    Toggle(isOn: $appManager.showKeyboardOnLaunch) {
                        Label("Show keyboard on launch", systemImage: "keyboard")
                    }
                    .tint(.green)

                    Button {
                        showDeleteChatsAlert = true
                    } label: {
                        Label("Delete all chats", systemImage: "trash")
                            .foregroundStyle(.red)
                    }
                    .alert("Delete all chats?", isPresented: $showDeleteChatsAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            deleteChats()
                        }
                    } message: {
                        Text("This will permanently delete all chats and messages. This cannot be undone.")
                    }

                    Button {
                        showResetApp = true
                    } label: {
                        Label("Reset App Completely", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    NavigationLink(destination: TermsView()) {
                        Label("Terms & Conditions", systemImage: "doc.text")
                    }

                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "lock")
                    }

                    NavigationLink(destination: LicenseView()) {
                        Label("Licenses", systemImage: "doc.plaintext")
                    }

                    Label("Version \(Bundle.main.releaseVersionNumber ?? "0") (\(Bundle.main.buildVersionNumber ?? "0"))", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                } header: {
                    Text("About")
                }

                Section {
                    Link(destination: URL(string: "https://voltaireai.app")!) {
                        HStack {
                            Label("Website", systemImage: "globe")
                            Spacer()
                            Text("voltaireai.app")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Link(destination: URL(string: "https://github.com/kilianbalaguer")!) {
                        HStack {
                            Label("Maker", systemImage: "person.circle")
                            Spacer()
                            Text("Kilian Balaguer")
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("More")
                } footer: {
                    VStack(spacing: 8) {
                        Text("Made in Morocco 🇲🇦")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        Image("brain.gear")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .adaptiveLogo()
                            .opacity(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }

            }
            .formStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomNavTitle(title: "Settings"))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss?()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .fullScreenCover(isPresented: $showResetApp) {
                NavigationStack {
                    ResetAppView()
                        .environmentObject(appManager)
                        .environment(llm)
                }
            }
        }
        .tint(appManager.appTintColor.getColor())
    }

    func deleteChats() {
        currentThread = nil
        do {
            let messages = try modelContext.fetch(FetchDescriptor<Message>())
            for message in messages {
                modelContext.delete(message)
            }
            let threads = try modelContext.fetch(FetchDescriptor<Thread>())
            for thread in threads {
                modelContext.delete(thread)
            }
            try modelContext.save()
            if appManager.shouldPlayHaptics {
                Haptic.shared.play(.medium)
            }
        } catch {
            print("Failed to delete chats:", error)
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

#Preview {
    SettingsView(currentThread: .constant(nil))
        .environmentObject(AppManager())
        .environment(LLMEvaluator())
}
