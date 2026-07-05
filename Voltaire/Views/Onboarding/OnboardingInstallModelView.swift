//
//  OnboardingInstallModelView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import MLXLMCommon
import SwiftUI
import Metal

struct OnboardingInstallModelView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @State private var deviceSupportsMetal3: Bool = true
    @Binding var showOnboarding: Bool
    @State var selectedModel = ModelConfiguration.defaultModel
    let suggestedModel = ModelConfiguration.defaultModel

    func sizeBadge(_ model: ModelConfiguration?) -> String? {
        guard let size = model?.modelSize else { return nil }
        if size < 1 {
            return "\(Int(truncating: (size * 1000) as NSNumber)) MB"
        }
        return "\(size) GB"
    }

    var modelsList: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.dotted")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .foregroundStyle(.primary, .tertiary)
                    
                    VStack(spacing: 4) {
                        Text("Install a model")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Select from models that are optimized for Apple Silicon")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
            
            if appManager.installedModels.count > 0 {
                Section(header: Text("Installed")) {
                    ForEach(appManager.installedModels, id: \.self) { modelName in
                        let model = ModelConfiguration.getModelByName(modelName)
                        Button(action: {}) {
                            HStack {
                                Text(appManager.modelDisplayName(modelName))
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                        .foregroundStyle(.secondary)
                        .disabled(true)
                    }
                }
            } else {
                Section(header: Text("Suggested")) {
                    Button { selectedModel = suggestedModel } label: {
                        HStack {
                            Text(appManager.modelDisplayName(suggestedModel.name))
                                .tint(.primary)
                            Spacer()
                            Image(systemName: selectedModel.name == suggestedModel.name ? "checkmark.circle.fill" : "circle")
                        }
                    }
                }
            }
            
            if filteredModels.count > 0 {
                Section(header: Text("Other Models")) {
                    ForEach(filteredModels, id: \.name) { model in
                        Button { selectedModel = model } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(appManager.modelDisplayName(model.name))
                                        .tint(.primary)
                                    if let size = model.modelSize {
                                        let sizeStr = size < 1 ? "\(Int(truncating: (size * 1000) as NSNumber)) MB" : "\(size) GB"
                                        Text(sizeStr)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                                Image(systemName: selectedModel.name == model.name ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            if deviceSupportsMetal3 {
                modelsList
                    .task {
                        checkModels()
                    }
                    .safeAreaInset(edge: .bottom, alignment: .center, spacing: 8) {
                        installButton
                            .padding(.horizontal, 12)
                            .padding(.bottom, 12)
                    }
            } else {
                DeviceNotSupportedView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip") {
                    appManager.hasSeenOnboarding = true
                    showOnboarding = false
                }
            }
        }
        .onAppear {
            checkMetal3Support()
        }
    }
    
    var installButton: some View {
        NavigationLink(destination: OnboardingDownloadingModelProgressView(showOnboarding: $showOnboarding, selectedModel: $selectedModel)) {
            Text("Install")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(.background)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .padding(.horizontal)
        .disabled(filteredModels.isEmpty)
    }

    var filteredModels: [ModelConfiguration] {
        ModelConfiguration.availableModels
            .filter { !appManager.installedModels.contains($0.name) }
            .filter { model in
                !(appManager.installedModels.isEmpty && model.name == suggestedModel.name)
            }
            .sorted { $0.name < $1.name }
    }

    func checkModels() {
        // automatically select the first available model
        if appManager.installedModels.contains(suggestedModel.name) {
            if let model = filteredModels.first {
                selectedModel = model
            }
        }
    }

    func checkMetal3Support() {
        if let device = MTLCreateSystemDefaultDevice() {
            deviceSupportsMetal3 = device.supportsFamily(.metal3)
        }
    }
}

#Preview {
    @Previewable @State var appManager = AppManager()

    OnboardingInstallModelView(showOnboarding: .constant(true))
        .environmentObject(appManager)
        .environment(LLMEvaluator())
}
