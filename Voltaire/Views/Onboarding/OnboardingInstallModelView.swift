//
//  OnboardingInstallModelView.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import MLXLMCommon
import SwiftUI
import Metal

struct OnboardingInstallModelView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @State private var deviceSupportsMetal3: Bool = true
    @Binding var selectedModel: ModelConfiguration
    var onInstall: () -> Void
    let suggestedModel = ModelConfiguration.defaultModel

    private struct FamilyGroup: Identifiable {
        let name: String
        let models: [ModelConfiguration]
        var id: String { name }
        var icon: String { getIcon(for: name) }
    }

    private var modelFamilies: [FamilyGroup] {
        Dictionary(grouping: filteredModels, by: { $0.familyName })
            .map { name, models in
                FamilyGroup(name: name, models: models.sorted { $0.name < $1.name })
            }
            .sorted { $0.name < $1.name }
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
                        if let model = ModelConfiguration.getModelByName(modelName) {
                            modelRow(model, isInstalledRow: true)
                        } else {
                            HStack {
                                Text(appManager.modelDisplayName(modelName))
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                Section(header: Text("Suggested")) {
                    modelRow(suggestedModel)
                }
            }

            ForEach(modelFamilies) { family in
                Section {
                    ForEach(family.models, id: \.name) { model in
                        modelRow(model)
                    }
                } header: {
                    HStack(spacing: 6) {
                        Image(family.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .modifier(ConditionalAdaptiveLogo(icon: family.icon))
                        Text(family.name)
                        Spacer()
                        Text(family.models.count > 1 ? "\(family.models.count) models" : "1 model")
                            .fontWeight(.regular)
                    }
                }
            }
        }
    }

    var body: some View {
        VStack {
            if deviceSupportsMetal3 {
                modelsList
                    .scrollContentBackground(.hidden)
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
        .onAppear {
            checkMetal3Support()
        }
    }

    var installButton: some View {
        Button(action: onInstall) {
            Text("Install")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .foregroundStyle(.background)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(.primary)
        .padding(.horizontal)
        .disabled(filteredModels.isEmpty)
    }

    @ViewBuilder
    private func modelRow(_ model: ModelConfiguration, isInstalledRow: Bool = false) -> some View {
        let isInstalled = isInstalledRow || appManager.installedModels.contains(model.name)
        let isSelected = !isInstalled && selectedModel.name == model.name
        let icon = getIcon(for: model.familyName)
        let tags = getModelTags(model)

        Button {
            if !isInstalled {
                if appManager.shouldPlayHaptics {
                    Haptic.shared.play(.light)
                }
                selectedModel = model
            }
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .modifier(ConditionalAdaptiveLogo(icon: icon))
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(appManager.modelDisplayName(model.name))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isInstalled ? .secondary : .primary)
                        .multilineTextAlignment(.leading)

                    Text(getModelDescription(model))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        if let sizeText = model.formattedSize {
                            Text(sizeText)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color(.systemGray6)))
                                .foregroundStyle(.secondary)
                        }
                        ForEach(tags.prefix(2), id: \.self) { tag in
                            TagBadge(tag: tag)
                        }
                    }
                    .padding(.top, 2)
                }

                Spacer(minLength: 8)

                if isInstalled {
                    Image(systemName: "checkmark")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                } else {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.primary : Color(.systemGray3))
                        .padding(.top, 2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isInstalled)
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
    @Previewable @State var selectedModel = ModelConfiguration.defaultModel

    OnboardingInstallModelView(selectedModel: $selectedModel, onInstall: {})
        .environmentObject(appManager)
        .environment(LLMEvaluator())
}
