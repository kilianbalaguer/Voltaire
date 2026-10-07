import SwiftUI
import MLXLMCommon
import Metal

// MARK: - MLX Storage Helpers

func getHFCacheURL() -> URL {
    let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    let hubURL = cachesDir.appendingPathComponent("huggingface/hub", isDirectory: true)
    
    print("📍 Storage checker using: \(hubURL.path)")
    return hubURL
}

func getRealModelsSize() -> String {
    let fileManager = FileManager.default
    let baseURL = getHFCacheURL()
    
    print("📊 Calculating real model size...")
    
    guard fileManager.fileExists(atPath: baseURL.path) else {
        print("   ❌ Folder does not exist yet")
        return "0 MB"
    }
    
    var total: UInt64 = 0
    let resourceKeys: [URLResourceKey] = [.isRegularFileKey, .fileSizeKey]
    
    if let enumerator = fileManager.enumerator(at: baseURL,
                                               includingPropertiesForKeys: resourceKeys,
                                               options: [.skipsHiddenFiles]) {
        
        for case let fileURL as URL in enumerator {
            if let values = try? fileURL.resourceValues(forKeys: Set(resourceKeys)),
               values.isRegularFile == true {
                total += UInt64(values.fileSize ?? 0)
            }
        }
    }
    
    let mb = Double(total) / (1024 * 1024)
    let result = mb >= 1024
        ? String(format: "%.2f GB", mb / 1024)
        : String(format: "%.1f MB", mb)
    
    print("   ✅ Total size calculated: \(result) (\(total) bytes)")
    return result
}

func deleteModel(modelId: String) {
    let fileManager = FileManager.default
    let baseURL = getHFCacheURL()

    let folderName = "models--" + modelId.replacingOccurrences(of: "/", with: "--")
    let modelURL = baseURL.appendingPathComponent(folderName)

    if fileManager.fileExists(atPath: modelURL.path) {
        do {
            try fileManager.removeItem(at: modelURL)
            print("Deleted:", folderName)
        } catch {
            print("Delete failed:", error)
        }
    } else {
        print("Model not found:", folderName)
    }
    
    // Clean up orphaned blobs
    cleanupOrphanedBlobs()
}

func cleanupOrphanedBlobs() {
    let fileManager = FileManager.default
    let baseURL = getHFCacheURL()
    let blobsURL = baseURL.appendingPathComponent("blobs")
    let refsURL = baseURL.appendingPathComponent("refs")
    
    // Get all remaining model folders
    guard let modelDirs = try? fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil) else { return }
    
    let modelFolders = modelDirs.filter { $0.lastPathComponent.hasPrefix("models--") }
    
    // Collect all referenced blob hashes from remaining models
    var referencedBlobs: Set<String> = []
    for modelDir in modelFolders {
        let snapshotsDir = modelDir.appendingPathComponent("snapshots")
        if let snapshotDirs = try? fileManager.contentsOfDirectory(at: snapshotsDir, includingPropertiesForKeys: nil) {
            for snapshotDir in snapshotDirs {
                if let files = try? fileManager.contentsOfDirectory(at: snapshotDir, includingPropertiesForKeys: nil) {
                    for file in files {
                        if let attrs = try? file.resourceValues(forKeys: [.isSymbolicLinkKey]),
                           attrs.isSymbolicLink == true,
                           let target = try? fileManager.destinationOfSymbolicLink(atPath: file.path) {
                            let blobName = URL(fileURLWithPath: target).lastPathComponent
                            referencedBlobs.insert(blobName)
                        }
                    }
                }
            }
        }
    }
    
    // Delete unreferenced blobs
    if fileManager.fileExists(atPath: blobsURL.path) {
        if let blobFiles = try? fileManager.contentsOfDirectory(at: blobsURL, includingPropertiesForKeys: nil) {
            for blobFile in blobFiles {
                let blobName = blobFile.lastPathComponent
                if !referencedBlobs.contains(blobName) {
                    try? fileManager.removeItem(at: blobFile)
                    print("Cleaned up orphaned blob:", blobName)
                }
            }
        }
    }
}

func deleteAllModelsAndCache() {
    let fileManager = FileManager.default
    let baseURL = getHFCacheURL()
    
    if fileManager.fileExists(atPath: baseURL.path) {
        do {
            try fileManager.removeItem(at: baseURL)
            print("Deleted entire HuggingFace cache")
        } catch {
            print("Failed to delete cache:", error)
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, point) in result.points.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + point.x, y: bounds.minY + point.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (points: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var points: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            points.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }
        
        return (points, CGSize(width: maxWidth, height: totalHeight))
    }
}

struct TagBadge: View {
    let tag: String
    
    var tagColor: Color {
        switch tag {
        case "Thinking": return .purple
        case "Recommended": return .green
        case "Best": return .green
        case "Vision": return .yellow
        case "New": return .orange
        case "High CPU Usage": return .red
        default: return .gray
        }
    }
    
    var iconName: String? {
        switch tag {
        case "Thinking": return "lightbulb.fill"
        case "Recommended": return "checkmark.circle.fill"
        case "Best": return "crown.fill"
        case "Vision": return "eye.fill"
        case "New": return "sparkles"
        case "High CPU Usage": return "cpu"
        default: return nil
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .font(.caption2)
            }
            Text(tag)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tagColor.opacity(0.15))
        .foregroundStyle(tagColor)
        .clipShape(Capsule())
    }
}

struct ModelFamilyRowView: View {
    let family: ModelFamily
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(family.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .modifier(ConditionalAdaptiveLogo(icon: family.icon))
                
                Text(family.name)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            
            Text(family.description)
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("\(family.models.count) models")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if !family.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(family.tags, id: \.self) { tag in
                        TagBadge(tag: tag)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct ModelFamily {
    let name: String
    let models: [ModelConfiguration]
    let description: String
    let icon: String
    let tags: [String]
}

struct ModelsSettingsView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    @Environment(\.dismiss) private var dismiss
    var isSheet: Bool = false
    @State private var downloadManager = DownloadManager.shared
    @State private var showDownloads = false
    @AppStorage("hasSeenModelSizesInfo") private var hasSeenModelSizesInfo = false
    @State private var deviceSupportsMetal3: Bool = true
    @State private var storageUsedString: String = "Calculating..."
    @State private var showDeleteAllModels = false
    
    var modelFamilies: [ModelFamily] {
        let grouped = Dictionary(grouping: ModelConfiguration.availableModels, by: { $0.familyName })
        
        return grouped.map { name, models in
            var allTags: [String] = []
            for model in models {
                let tags = getModelTags(model)
                for tag in tags {
                    if !allTags.contains(tag) {
                        allTags.append(tag)
                    }
                }
            }
            
            return ModelFamily(
                name: name,
                models: models.sorted { $0.name < $1.name },
                description: getDescription(for: name),
                icon: getIcon(for: name),
                tags: allTags
            )
        }.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List {
            if !hasSeenModelSizesInfo {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Understanding Model Sizes")
                                .font(.headline)
                            Spacer()
                            Button {
                                hasSeenModelSizesInfo = true
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        Text("Local models come in different sizes, defined by their number of parameters, usually measured in billions (e.g., 0.6B, 1B, 3B). Bigger models are usually smarter, but also slower, as they use more memory and processing power. Choose a model that balances speed and quality for your needs.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                ForEach(modelFamilies, id: \.name) { family in
                    NavigationLink(destination: ModelFamilyDetailView(family: family).environmentObject(appManager).environment(llm)) {
                        ModelFamilyRowView(family: family)
                    }
                }
            } header: {
                Text("Models")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .textCase(nil)
            }
            
            Section {
                HStack {
                    Text("Storage used")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(storageUsedString)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section {
                Button {
                    showDeleteAllModels = true
                } label: {
                    Text("Delete all models")
                        .foregroundStyle(.red)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("On-device AI models may produce inaccurate or incomplete responses. Please verify critical information and double-check responses.")
                    Text("Models are provided by **huggingface.co**.")
                }
                .padding(.top, 8)
            }
        }
        .navigationTitle("Manage models")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isSheet {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showDownloads = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "arrow.down.circle")
                        if downloadManager.activeCount > 0 {
                            Text("\(downloadManager.activeCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(4)
                                .background(Circle().fill(.red))
                                .offset(x: 8, y: -8)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showDownloads) {
            NavigationStack {
                DownloadsListView()
            }
        }
        .fullScreenCover(isPresented: $showDeleteAllModels) {
            NavigationStack {
                DeleteAllModelsView()
                    .environmentObject(appManager)
                    .environment(llm)
            }
        }
        .onAppear {
            refreshStorageMetrics()
            if let device = MTLCreateSystemDefaultDevice() {
                deviceSupportsMetal3 = device.supportsFamily(.metal3)
            }
        }
        .onChange(of: appManager.installedModels.count) { _, _ in
            refreshStorageMetrics()
        }
        .navigationPopGestureDisabled(true)
    }
    
    private func refreshStorageMetrics() {
        Task(priority: .background) {
            let actualSizeString = getRealModelsSize()
            await MainActor.run {
                self.storageUsedString = actualSizeString
            }
        }
    }
    
    func getDescription(for family: String) -> String {
        switch family {
        case "Bonsai": return "A new class of ultra-efficient models from PrismML. Built for performance where it matters most: on-device and in real time."
        case "Qwen 3.5": return "Qwen 3.5 models from the Qwen team. Supports 201 languages and dialects, with strong reasoning and visual understanding."
        case "LFM 2.5": return "A new generation of hybrid models developed by Liquid AI. Improved performance compared to LFM 2 and designed for on-device deployment."
        case "LFM 2": return "A family of hybrid models developed by Liquid AI. Designed for on-device deployment."
        case "Ministral 3": return "Edge-optimized multimodal models from Mistral AI. Great vision capabilities, support for dozens of languages, and strong adherence to system prompts."
        case "SmolLM 3": return "Small but powerful model by Hugging Face. Great for complex reasoning, long conversations, and use in English, French, Spanish, German, Italian, and Portuguese."
        case "Gemma 3n": return "Powerful models from Google. Optimized for use in mobile devices. Best for content creation, text summarization, and conversational AI."
        case "Gemma 2": return "Lightweight and efficient models from Google. Tailored for English-language tasks and communication."
        case "Granite 4.0": return "The latest models from IBM. Delivers industry-leading performance in tasks like instruction following. Optimized for edge deployments with remarkable inference efficiency."
        case "LLaMa 3.2": return "Small models from Meta. Good for multilingual dialogue and summarization tasks."
        case "Qwen 3": return "Powerful models from the Qwen team, including both text and vision-language models. Supports over 100 languages and excels at creative writing and role-playing."
        default: return "High performance AI model"
        }
    }
    
    func getIcon(for family: String) -> String {
        switch family {
        case "Bonsai": return "Bonsai"
        case "Qwen 3", "Qwen 3.5": return "Gwen"
        case "LFM 2", "LFM 2.5": return "LFM"
        case "Ministral 3": return "Ministral"
        case "SmolLM 3": return "SmolLM"
        case "Gemma 2", "Gemma 3n": return "Gemma"
        case "Granite 4.0": return "Granite"
        case "LLaMa 3.2", "Llama 3.2": return "LlaMa"
        default: return "Gemma"
        }
    }
}

struct ModelFamilyDetailView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(LLMEvaluator.self) var llm
    let family: ModelFamily
    @State private var downloadManager = DownloadManager.shared
    
    var body: some View {
        List {
            ForEach(family.models, id: \.name) { model in
                ModelRowView(
                    model: model,
                    icon: family.icon,
                    isInstalled: appManager.installedModels.contains(model.name),
                    isDownloading: downloadManager.isDownloading(model.name),
                    downloadProgress: downloadManager.progress(for: model.name),
                    downloadETA: downloadManager.eta(for: model.name),
                    onDownload: { downloadManager.startDownload(model: model, llm: llm, appManager: appManager) },
                    onStop: { downloadManager.cancelDownload(named: model.name) },
                    onSelect: { selectModel(model) }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    if appManager.installedModels.contains(model.name) && !downloadManager.isDownloading(model.name) {
                        selectModel(model)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if appManager.installedModels.contains(model.name) {
                        Button(role: .destructive) {
                            removeModel(model)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .environmentObject(appManager)
            }
        }
        .navigationTitle(family.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationPopGestureDisabled(true)
    }
    
    private func removeModel(_ model: ModelConfiguration) {
        if llm.modelConfiguration.name == model.name {
            llm.loadState = .idle
        }
        
        // Fix: Safely unpacks the Identifier enum for single-row swipe deletion too
        switch model.id {
        case .id(let repoId, _):
            deleteModel(modelId: repoId)
        case .directory(let url):
            deleteModel(modelId: url.lastPathComponent)
        }
        
        if let index = appManager.installedModels.firstIndex(of: model.name) {
            appManager.installedModels.remove(at: index)
        }

        if appManager.currentModelName == model.name {
            appManager.currentModelName = nil
        }
    }
    
    private func selectModel(_ model: ModelConfiguration) {
        Task {
            appManager.currentModelName = model.name
            appManager.playHaptic()
            await llm.switchModel(model)
        }
    }
}

func getModelDescription(_ model: ModelConfiguration) -> String {
    // Bonsai
    if model.name.contains("Bonsai") && model.name.contains("Ternary") {
        return "The largest 1.58-bit Bonsai model from PrismML. A bigger, smarter model engineered for efficient on-device inference, delivering strong performance and fast execution. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("Bonsai") {
        return "PrismML's flagship 1-bit Bonsai model. Engineered to deliver powerful intelligence for on-device systems. Recommended for iPhone 15 Pro and newer."
    }
    // Qwen 3.5
    else if model.name.contains("Qwen3.5") && model.name.contains("2B") {
        return "Lightweight model with strong vision capabilities and hybrid reasoning. Great for general-purpose conversation. Recommended for iPhone 15 and newer."
    } else if model.name.contains("Qwen3.5") && model.name.contains("0.8B") {
        return "Small model with good vision capabilities and hybrid reasoning. Great for simple conversation and fast answers. Recommended for iPhone 14 and newer."
    }
    // LFM 2.5
    else if model.name.contains("LFM2.5") && model.name.contains("VL") && model.name.contains("1.6B") {
        return "An updated vision-language model from Liquid AI. Enhanced performance over LFM 2 VL with improved multilingual vision understanding. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("LFM2.5") && model.name.contains("VL") && model.name.contains("450M") {
        return "A compact vision-language model from Liquid AI. Built on the LFM 2.5 backbone with stronger multilingual image understanding. Great for Shortcut use. Recommended for iPhone 14 and older."
    } else if model.name.contains("LFM2.5") && model.name.contains("Thinking") {
        return "A reasoning model from Liquid AI. Optimized for reasoning-heavy tasks like math and programming. Provides enhanced problem-solving capabilities with efficient performance. Recommended for iPhone 15 and newer."
    } else if model.name.contains("LFM2.5") && model.name.contains("1.2B") {
        return "A new generation of hybrid models developed by Liquid AI. Best-in-class performance for it's size. Suited for data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 15 and older."
    } else if model.name.contains("LFM2.5") && model.name.contains("350M") {
        return "A compact model from Liquid AI's LFM 2.5 family. Best for fast everyday chat, summarization, and lightweight drafting on constrained devices. Recommended for iPhone 14 and older."
    }
    // LFM 2
    else if model.name.contains("LFM2") && model.name.contains("VL") && model.name.contains("3B") {
        return "A vision-language model from Liquid AI. Delivers competitive multimodal performance among lightweight open models, with enhanced visual understanding and efficient inference. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("LFM2") && model.name.contains("VL") && model.name.contains("1.6B") {
        return "A vision-language model from Liquid AI. Optimized for real-world performance. Supports multilingual visual understanding, and delivers reliable results on complex images and OCR. Recommended for iPhone 15 and newer."
    } else if model.name.contains("LFM2") && model.name.contains("VL") && model.name.contains("450M") {
        return "A small vision-language model from Liquid AI. With only 450M parameters, it achieves competitive performance for image description and visual question answering. Recommended for iPhone 14 and older."
    } else if model.name.contains("LFM2") && model.name.contains("Exp") {
        return "An experimental version of LFM2 (2.6B) trained on instruction following, knowledge, and math, it delivers particularly strong performance compared to other 3B models. Designed for advanced data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("LFM2") && model.name.contains("2.6B") {
        return "A new generation of hybrid models developed by Liquid AI. Suited for data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("LFM2") && model.name.contains("1.2B") {
        return "A new generation of hybrid models developed by Liquid AI. Suited for data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 15 and older."
    } else if model.name.contains("LFM2") && model.name.contains("700M") {
        return "A new generation of hybrid models developed by Liquid AI. Suited for data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 14 and newer."
    } else if model.name.contains("LFM2") && model.name.contains("350M") {
        return "A new generation of hybrid models developed by Liquid AI. Suited for data extraction, RAG, creative writing, and multi-turn conversations. Recommended for iPhone 14 and older."
    }
    // Ministral 3
    else if model.name.contains("Ministral") {
        return "Ministral 3B is an edge-optimized multimodal model. It analyzes images and text, supports dozens of languages, and adheres strongly to system prompts. Ideal for image captioning, translation, and data extraction. Recommended for iPhone 15 Pro or newer."
    }
    // SmolLM 3
    else if model.name.contains("SmolLM") {
        return "A model made by Hugging Face. Great for complex reasoning, long conversations, and use in English, French, Spanish, German, Italian, and Portuguese. Recommended for iPhone 15 Pro or newer."
    }
    // Gemma 3n
    else if model.name.contains("gemma-3n") {
        return "A powerful model from Google. Optimized for use in everyday devices. Great for content creation, text summarization, and conversational AI. Recommended for iPhone 15 Pro and newer."
    }
    // Gemma 2
    else if model.name.contains("gemma-2") {
        return "A model from Google. Tailored for English-language tasks and communication. Recommended for iPhone 15 Pro and newer."
    }
    // Granite 4.0
    else if model.name.contains("granite-4.0") && model.name.contains("micro") {
        return "The latest dense hybrid 3B parameters model from IBM. Delivers strong performance across benchmarks with industry-leading results in tasks like instruction following. Optimized for edge deployments with remarkable inference efficiency. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("granite-4.0") && model.name.contains("1b") {
        return "The latest dense hybrid ~1.5B parameters model from IBM. Delivers strong performance across benchmarks against models of similar size. Optimized for edge deployments with remarkable inference efficiency. Recommended for iPhone 15 and older."
    } else if model.name.contains("granite-4.0") && model.name.contains("350m") {
        return "The latest dense hybrid 350M parameters model from IBM. Delivers strong performance across benchmarks against models of similar size. Optimized for edge deployments with remarkable inference efficiency. Recommended for iPhone 14 and older."
    }
    // Llama 3.2
    else if model.name.contains("Llama") && model.name.contains("3B") {
        return "A model from Meta. Good for multilingual dialogue and summarization tasks. Recommended for iPhone 15 Pro and newer."
    } else if model.name.contains("Llama") && model.name.contains("1B") {
        return "A fast model from Meta. Good for basic multilingual dialogue and summarization tasks. Recommended for iPhone 15 and older."
    }
    // Qwen 3
    else if model.name.contains("Qwen3") && model.name.contains("VL") {
        return "A compact vision-language model from the Qwen series. Delivers superior text understanding & generation with deeper visual perception in a smaller package. Recommended for iPhone 15 and newer."
    } else if model.name.contains("Qwen3") && model.name.contains("Thinking") && model.name.contains("4B") {
        return "Updated Qwen 3 2507 thinking model from the Qwen team, with significant improvements in general capabilities compared to the Qwen 3 Hybrid Thinking models. Recommended for iPhone 15 Pro or newer."
    } else if model.name.contains("Qwen3") && model.name.contains("4B") {
        return "Updated Qwen 3 2507 model from the Qwen team, with significant improvements in general capabilities compared to the Qwen 3 Hybrid Thinking models. Recommended for iPhone 15 Pro or newer."
    } else if model.name.contains("Qwen3") && model.name.contains("1.7B") {
        return "The latest model from the Qwen team. It supports over 100 languages and excels at coding, creative writing, and role-playing. Recommended for iPhone 15 and older."
    } else if model.name.contains("Qwen3") && model.name.contains("0.6B") {
        return "The latest model from the Qwen team. It supports over 100 languages and is great for lightweight coding, creative writing, and role-playing. Recommended for iPhone 14 and older."
    }
    return "A powerful AI model capable of general purpose language tasks."
}

func getModelTags(_ model: ModelConfiguration) -> [String] {
    // Bonsai
    if model.name.contains("Bonsai") && model.name.contains("Ternary") {
        return ["New"]
    } else if model.name.contains("Bonsai") {
        return ["New", "Best"]
    }
    // Qwen 3.5
    else if model.name.contains("Qwen3.5") && model.name.contains("2B") {
        return ["Thinking", "Vision"]
    } else if model.name.contains("Qwen3.5") && model.name.contains("0.8B") {
        return ["Vision"]
    }
    // LFM 2.5
    else if model.name.contains("LFM2.5") && model.name.contains("VL") && model.name.contains("1.6B") {
        return ["Vision", "Recommended"]
    } else if model.name.contains("LFM2.5") && model.name.contains("VL") && model.name.contains("450M") {
        return ["New", "Vision"]
    } else if model.name.contains("LFM2.5") && model.name.contains("Thinking") {
        return ["Thinking"]
    } else if model.name.contains("LFM2.5") && model.name.contains("350M") {
        return ["New"]
    }
    // LFM 2
    else if model.name.contains("LFM2") && model.name.contains("VL") {
        return ["Vision"]
    }
    // Ministral 3
    else if model.name.contains("Ministral") {
        return ["Vision", "High CPU Usage"]
    }
    // SmolLM 3
    else if model.name.contains("SmolLM") {
        return ["Thinking"]
    }
    // Qwen 3
    else if model.name.contains("Qwen3") && model.name.contains("VL") {
        return ["Vision"]
    } else if model.name.contains("Qwen3") && model.name.contains("Thinking") {
        return ["Thinking"]
    } else if model.name.contains("Qwen3") && model.name.contains("1.7B") {
        return ["Thinking"]
    } else if model.name.contains("Qwen3") && model.name.contains("0.6B") {
        return ["Thinking"]
    }
    return []
}

struct ModelRowView: View {
    @EnvironmentObject var appManager: AppManager
    let model: ModelConfiguration
    let icon: String
    let isInstalled: Bool
    let isDownloading: Bool
    let downloadProgress: Double
    let downloadETA: String?
    let onDownload: () -> Void
    let onStop: () -> Void
    let onSelect: () -> Void
    
    var isSelected: Bool {
        appManager.currentModelName == model.name
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .modifier(ConditionalAdaptiveLogo(icon: icon))
                
                Text(appManager.modelDisplayName(model.name))
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if isInstalled {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                } else if isDownloading {
                    Button(action: onStop) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(action: onDownload) {
                        Text("Download")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .foregroundStyle(.secondary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text(getModelDescription(model))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
            if let sizeText = model.formattedSize {
                Text(sizeText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            let tags = getModelTags(model)
            if !tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        TagBadge(tag: tag)
                    }
                }
            }
            
            if isDownloading {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        ProgressView(value: downloadProgress)
                            .tint(.secondary)
                        Text("\(Int(downloadProgress * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .frame(width: 40)
                    }
                    if let eta = downloadETA {
                        Text("ETA: \(eta)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }
}
