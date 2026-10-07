//
//  ChatsSettingsView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/6/24.
//

import SwiftUI
import SwiftData

struct ChatsSettingsView: View {
    @EnvironmentObject var appManager: AppManager
    @State private var draftInstructions: String = ""
    @State private var draftTemperature: String = "Default"

    private let instructionsLimit = 1000

    var isDirty: Bool {
        draftInstructions != appManager.systemPrompt || draftTemperature != appManager.customTemperature
    }

    var body: some View {
        Form {
            if appManager.userInterfaceIdiom == .phone {
                Section {
                    Toggle("Haptics", isOn: $appManager.shouldPlayHaptics)
                        .tint(.green)
                }
            }

            Section {
                Toggle("Enable customization", isOn: $appManager.customizationEnabled)
                    .tint(.green)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Instructions")
                        .font(.headline)
                        .foregroundStyle(appManager.customizationEnabled ? .primary : .secondary)
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $draftInstructions)
                            .frame(minHeight: 120)
                            .disabled(!appManager.customizationEnabled)
                            .foregroundStyle(appManager.customizationEnabled ? .primary : .secondary)
                            .onChange(of: draftInstructions) { _, newValue in
                                if newValue.count > instructionsLimit {
                                    draftInstructions = String(newValue.prefix(instructionsLimit))
                                }
                            }
                        if draftInstructions.isEmpty {
                            Text("Customize how the AI responds")
                                .foregroundStyle(.tertiary)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 8)
                                .allowsHitTesting(false)
                        }
                    }
                    HStack {
                        Spacer()
                        Text("\(draftInstructions.count)/1.000")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                Menu {
                    ForEach(AppManager.temperatureOptions, id: \.self) { option in
                        Button {
                            draftTemperature = option
                        } label: {
                            HStack {
                                Text(option)
                                if option == draftTemperature {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        .disabled(!appManager.customizationEnabled)
                    }
                } label: {
                    HStack {
                        Text("Temperature")
                            .foregroundStyle(appManager.customizationEnabled ? .primary : .secondary)
                        Spacer()
                        Text(draftTemperature)
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } footer: {
                Text("Controls randomness in responses. Lower values make the AI more focused and deterministic, while higher values make it more creative and unpredictable.")
            }
        }
        .formStyle(.grouped)
        .modifier(CustomNavTitle(title: "Chats"))
        .navigationPopGestureDisabled(true)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    appManager.systemPrompt = draftInstructions
                    appManager.customTemperature = draftTemperature
                    if appManager.shouldPlayHaptics {
                        Haptic.shared.play(.light)
                    }
                }
                .disabled(!appManager.customizationEnabled || !isDirty)
            }
        }
        .onAppear {
            draftInstructions = appManager.systemPrompt
            draftTemperature = appManager.customTemperature
        }
    }
}

#Preview {
    ChatsSettingsView()
        .environmentObject(AppManager())
}
