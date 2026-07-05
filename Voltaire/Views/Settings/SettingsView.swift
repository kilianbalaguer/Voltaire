//
//  SettingsView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    @Environment(LLMEvaluator.self) var llm
    @Binding var currentThread: Thread?
    @State private var showResetApp = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("App") {
                    NavigationLink(destination: ModelsSettingsView()) {
                        Label("Manage models", systemImage: "cube")
                    }

                    NavigationLink(destination: ChatsSettingsView(currentThread: $currentThread)) {
                        Label("Personalization", systemImage: "person")
                    }

                    Toggle(isOn: $appManager.showKeyboardOnLaunch) {
                        Label("Show keyboard on launch", systemImage: "keyboard")
                    }
                }

                Section("About") {
                    NavigationLink(destination: TermsView()) {
                        Label("Terms & Conditions", systemImage: "doc.text")
                    }

                    NavigationLink(destination: PrivacyView()) {
                        Label("Privacy Policy", systemImage: "lock")
                    }

                    NavigationLink(destination: CreditsView()) {
                        Label("Licenses", systemImage: "doc.plaintext")
                    }

                    Label("Version \(Bundle.main.releaseVersionNumber ?? "0").\(Bundle.main.buildVersionNumber ?? "0")", systemImage: "info.circle")
                        .foregroundStyle(.secondary)
                }

                Section("Danger Zone") {
                    Button {
                        showResetApp = true
                    } label: {
                        Label("Reset App Completely", systemImage: "arrow.counterclockwise")
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationBarTitleDisplayMode(.inline)
            .modifier(CustomNavTitle(title: "Settings"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
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
        .interactiveDismissDisabled(true)
        .tint(appManager.appTintColor.getColor())
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
