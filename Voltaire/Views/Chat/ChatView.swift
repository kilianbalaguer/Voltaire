//
//  ChatView.swift
//  Voltaire
//
//  Created by Kilian Balaguer on 10/7/26.
//

import SwiftUI
import MLXLMCommon
import Shimmer
import PhotosUI
import UniformTypeIdentifiers
#if os(iOS)
import UIKit
#endif

struct ChatView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Binding var currentThread: Thread?
    @Environment(LLMEvaluator.self) var llm
    @Namespace var bottomID
    @State var showModelPicker = false
    @State var prompt = ""
    @FocusState.Binding var isPromptFocused: Bool
    @Binding var showOnboarding: Bool
    @Binding var isMenuExpanded: Bool
    var menuProgress: CGFloat = 0

    @State var thinkingTime: TimeInterval?
    
    @State private var generatingThreadID: UUID?
    @State private var showNoModelAlert = false
    @State private var showFeatureWarning = false
    #if os(iOS)
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotosPicker = false
    @State private var showCamera = false
    @State private var showFileImporter = false
    #endif

    var currentModelSupportsVision: Bool {
        guard let modelName = appManager.currentModelName,
              let model = ModelConfiguration.getModelByName(modelName) else { return false }
        return model.supportsVision
    }

    var canSendMessage: Bool {
        if !isPromptEmpty { return true }
        #if os(iOS)
        return selectedImage != nil
        #else
        return false
        #endif
    }

    #if os(iOS)
    var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func downscaledJPEGData(_ image: UIImage, maxDimension: CGFloat = 1024) -> Data? {
        let size = image.size
        guard size.width > 0, size.height > 0 else { return nil }
        let scale = min(1, maxDimension / max(size.width, size.height))
        if scale >= 1 {
            return image.jpegData(compressionQuality: 0.8)
        }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }
    #endif
    @State private var homeGreeting = ""
    @AppStorage("launchCount") private var launchCount = 0
    
    public var isPreview = false

    @Environment(\.colorScheme) private var colorScheme

    /// Contrast text against the glassProminent fill (light button → dark text, dark button → light text)
    private var newChatForeground: Color {
        let tint = appManager.appTintColor.getColor()
        if tint == .primary {
            return colorScheme == .dark ? .black : .white
        }
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard UIColor(tint).getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return .white
        }
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6 ? .black : .white
    }

    var greetingTexts: [String] {
        let name = appManager.userName
        let greet = name.isEmpty ? "" : ", \(name)"
        var texts = [
            "Hello\(greet)",
            "What's up\(greet)?",
            "Hey\(greet)",
            "What shall we build today\(greet)?",
            "Ready when you are\(greet)",
            "Let's create something amazing\(greet)",
            "How can I help you\(greet)?",
            "What's on your mind\(greet)?",
            "Let's get started\(greet)",
            "Your ideas, let's go\(greet)",
            "What are we working on\(greet)?",
            "Ready to brainstorm\(greet)?",
            "Let's make it happen\(greet)",
            "What's the plan\(greet)?",
            "Here to help\(greet)",
            "Let's do this\(greet)",
            "What's next\(greet)?",
            "Thinking with you\(greet)",
            "Let's explore ideas\(greet)",
            "What shall we create\(greet)?",
            "I'm all ears\(greet)",
            "Let's bring ideas to life\(greet)",
            "What are we cooking\(greet)?",
            "Ready to innovate\(greet)?",
            "Let's build something cool\(greet)",
            "What's the mission\(greet)?",
            "Time to create\(greet)!",
            "Let's go\(greet)!",
            "What's the vibe\(greet)?",
            "Ready to roll\(greet)?",
            "Let's get creative\(greet)",
            "What shall we explore\(greet)?",
            "Here to assist\(greet)",
            "Let's make magic\(greet)",
            "What's the goal\(greet)?"
        ]
        if launchCount > 1 {
            texts.insert("Welcome back\(greet)", at: 0)
            texts.insert("Nice to see you again\(greet)", at: 1)
            texts.insert("Let's pick up where we left off\(greet)", at: 2)
            texts.insert("Back for more\(greet)?", at: 3)
        }
        return texts
    }
    
    var isPromptEmpty: Bool {
        prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    let platformBackgroundColor: Color = {
        return Color(UIColor.secondarySystemBackground)
    }()
    
    let platformLabelColor: Color = {
        return Color(UIColor.label)
    }()
    
    var chatTextField: some View {
        Group {
            if appManager.hasInstalledModels {
                TextField((currentThread?.sortedMessages.count ?? 0) == 0 ? "Ask anything" : "Send a message", text: $prompt, axis: .vertical)
                    .focused($isPromptFocused)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .lineLimit(3)
                    .padding(.vertical, 8)
                    .frame(minHeight: 48)
                    .onSubmit {
                        isPromptFocused = true
                        generate()
                    }
            } else {
                Text("Install a model to start chatting")
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(minHeight: 48)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        showNoModelAlert = true
                    }
            }
        }
    }
    
    /// Thinking switch only for models with a real no-think mechanism
    /// (Qwen template flag, SmolLM3 system flag). LFM always thinks.
    var showThinkingSwitch: Bool {
        guard let modelName = appManager.currentModelName,
              let model = ModelConfiguration.getModelByName(modelName) else { return false }
        return model.supportsThinkingSwitch
    }

    var chatInput: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Menu {
                Button {
                    #if os(iOS)
                    showFileImporter = true
                    #else
                    showFeatureWarning = true
                    #endif
                } label: {
                    Label("Attach File", systemImage: "doc")
                }
                .disabled(!appManager.hasInstalledModels || !currentModelSupportsVision)

                #if os(iOS)
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                .disabled(!appManager.hasInstalledModels || !currentModelSupportsVision || !isCameraAvailable)

                Button {
                    showPhotosPicker = true
                } label: {
                    Label("Attach Photo", systemImage: "photo")
                }
                .disabled(!appManager.hasInstalledModels || !currentModelSupportsVision)
                #else
                Button {
                    showFeatureWarning = true
                } label: {
                    Label("Take Photo", systemImage: "camera")
                }
                .disabled(false)

                Button {
                    showFeatureWarning = true
                } label: {
                    Label("Attach Photo", systemImage: "photo")
                }
                .disabled(false)
                #endif
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
            }
            .disabled(!appManager.hasInstalledModels)
            #if os(iOS)
            .photosPicker(isPresented: $showPhotosPicker, selection: $photoItem, matching: .images)
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.image]) { result in
                guard case .success(let url) = result else { return }
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }
                guard let data = try? Data(contentsOf: url),
                      let uiImage = UIImage(data: data) else { return }
                selectedImage = uiImage
            }
            .sheet(isPresented: $showCamera) {
                CameraImagePicker(image: $selectedImage)
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                    }
                    photoItem = nil
                }
            }
            #endif

            if showThinkingSwitch {
                Button {
                    if appManager.shouldPlayHaptics {
                        Haptic.shared.play(.light)
                    }
                    appManager.thinkingModeOn.toggle()
                } label: {
                    Image(systemName: appManager.thinkingModeOn ? "lightbulb.fill" : "lightbulb")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(appManager.thinkingModeOn ? Color.green : Color.primary)
                        .frame(width: 48, height: 48)
                        .background {
                            if appManager.thinkingModeOn {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color.green.opacity(0.15))
                            } else {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial)
                            }
                        }
                }
                .buttonStyle(.plain)
                .disabled(!appManager.hasInstalledModels)
                .opacity(appManager.hasInstalledModels ? 1 : 0.5)
                .accessibilityLabel(appManager.thinkingModeOn ? "Thinking on" : "Thinking off")
            }
            
            HStack(alignment: .bottom, spacing: 0) {
                if #available(iOS 18.0, *) {
                    chatTextField
                        .writingToolsBehavior(.disabled)
                } else {
                    chatTextField
                }
                generateButton
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
        }
        .alert("Coming Soon", isPresented: $showFeatureWarning) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("File and photo support is being worked on. Check back later.")
        }
    }
    
    var modelPickerButton: some View {
        Button {
            if appManager.shouldPlayHaptics {
                Haptic.shared.play(.heavy)
            }
            showModelPicker.toggle()
        } label: {
            Group {
                Image(systemName: "brain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16)
                    .tint(.primary)
            }
            .frame(width: 48, height: 48)
            .background(
                Circle()
                    .fill(platformBackgroundColor)
            )
        }
    }
    
    var modelPickerMenu: some View {
        Menu(content: {
                
                if appManager.userInterfaceIdiom == .phone {
                    Section(chatTitle) {
                        Button("Rename", systemImage: "pencil") {
                            UIApplication.shared.alertWithTextField(title: "Rename Chat", body: "", placeholder: (currentThread?.title ?? ""), onOK: {new in
                                if !new.isEmpty {
                                    currentThread?.title = new
                                }
                            })
                        }
                    }
                }
                
                Section(appManager.userInterfaceIdiom == .phone ? "Models" : "Installed") {
                    ForEach(appManager.installedModels, id: \.self) { modelName in
                        Button {
                            Task {
                                if let model = ModelConfiguration.availableModels.first(where: {
                                    $0.name == modelName
                                }) {
                                    appManager.currentModelName = modelName
                                    if appManager.shouldPlayHaptics {
                                        Haptic.shared.play(.medium)
                                    }
                                    await llm.switchModel(model)
                                }
                            }
                        } label: {
                            Label {
                                HStack(spacing: 4) {
                                    Text(appManager.modelDisplayName(modelName))
                                    if let params = appManager.modelParameterCount(modelName) {
                                        Text(params)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            } icon: {
                                Image(systemName: appManager.currentModelName == modelName ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    }
                    
                    Button {
                        showModelPicker.toggle()
                    } label: {
                        Label("Download more models...", systemImage: "arrow.down.circle.dotted")
                    }
                }
            }, label: {
            if appManager.userInterfaceIdiom == .phone {
                HStack(spacing: 4) {
                    Text(ModelConfiguration.getModelByName(appManager.currentModelName ?? "")?.familyName ?? chatTitle)
                        .font(.headline)
                    if let params = appManager.modelParameterCount(appManager.currentModelName ?? "") {
                        Text(params)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                }
            } else {
                Image(systemName: "brain")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        })
        .tint(platformLabelColor)
        .onTapGesture {
            if appManager.shouldPlayHaptics {
                Haptic.shared.play(.light)
            }
        }
    }
    
    var generateButton: some View {
        Button {
            if llm.running {
                llm.stop()
            } else {
                generate()
            }
        } label: {
            Image(systemName: llm.running ? "stop.circle.fill" : "arrow.up.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
        .disabled((!canSendMessage && !llm.running) || (llm.running && llm.cancelled))
        .animation(.default, value: llm.running)
        .animation(.default, value: isPromptEmpty)
        .padding(.trailing, 12)
        .padding(.bottom, 12)
    }
    
    var chatTitle: String {
        if let currentThread = currentThread,
        let title =  currentThread.title{
           return title
//            if let firstMessage = currentThread.sortedMessages.first {
//                return firstMessage.content
//            }
        }
        
         return "New Chat"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let currentThread = currentThread {
                    ConversationView(thread: currentThread, generatingThreadID: generatingThreadID)
                        .background(.clear)
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        TypingGreetingView(
                            texts: greetingTexts,
                            typingSpeed: 0.06,
                            backspaceSpeed: 0.03,
                            pauseAfterType: 2.5,
                            pauseAfterDelete: 0.5,
                            isActive: currentThread == nil && !isMenuExpanded && !showModelPicker && !showOnboarding && appManager.splashComplete
                        )
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top, 170)

                        Spacer()
                    }
                    .background {
                        SyncedChatGradientBackground()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .mask {
                            SideMenuPanelShape.make()
                                .fill(.white)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                        }
                    }
                    .transition(.opacity)
                    .ignoresSafeArea(edges: .all)
                }
}
        .animation(.easeInOut(duration: 0.4), value: currentThread != nil)
        .onChange(of: newChatTriggered) { _, triggered in
            if triggered {
                prompt = ""
                currentThread = nil
                isPromptFocused = true
                newChatTriggered = false
            }
        }
            .onTapGesture {
                isPromptFocused = false
            }
            .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
                if !isPreview {
                    VStack(spacing: 0) {
                        if case .loading = llm.loadState {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .tint(.primary)
                                Text("Loading model...")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                    .shimmering()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect()
                            .padding(.bottom, 6)
                        }

                        #if os(iOS)
                        if let selectedImage {
                            HStack {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 56, height: 56)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Spacer()
                                Button {
                                    self.selectedImage = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 4)
                            .padding(.bottom, 6)
                        }
                        #endif

                        ZStack(alignment: .bottom) {
                            VariableBlurView(maxBlurRadius: 4, direction: .blurredBottomClearTop, startOffset: 0.1)
                                .frame(maxWidth: .infinity)
                                .frame(height: 116)
                                .offset(y: 26)
                                .ignoresSafeArea(.all)
                            chatInput
                                .padding()
                                .padding(.bottom, 10)
                                .ignoresSafeArea(edges: [])
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 90)
                        .ignoresSafeArea(.all)
                    }
                }
            }
            .if(!isPreview && appManager.userInterfaceIdiom != .phone) {v in
                v
                    .modifier(CustomNavTitle(title: chatTitle))
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showModelPicker) {
                NavigationStack {
                    ModelsSettingsView(isSheet: true)
                        .environmentObject(appManager)
                        .environment(llm)
                        .interactiveDismissDisabled(true)
                }
            }
            .alert("No Model Installed", isPresented: $showNoModelAlert) {
                Button("Install Model") {
                    showModelPicker = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please install a model first to start chatting.")
            }
            .toolbar {
                if !isPreview {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isMenuExpanded.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        modelPickerMenu
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            newChatTriggered = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(appManager.hasInstalledModels && currentThread != nil ? .primary : .secondary)
                        }
                        .disabled(!appManager.hasInstalledModels || currentThread == nil)
                    }
                }
            }
        }
        .background {
            Color(.systemBackground)
                .ignoresSafeArea()
        }
        .scrollContentBackground(.hidden)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func generateGreeting() {
        launchCount += 1
        let hour = Calendar.current.component(.hour, from: Date())
        let name = appManager.userName
        
        let timeGreeting: String
        switch hour {
        case 5..<12: timeGreeting = "Good morning"
        case 12..<17: timeGreeting = "Good afternoon"
        case 17..<21: timeGreeting = "Good evening"
        default: timeGreeting = "Hello"
        }
        
        if launchCount == 1 {
            homeGreeting = name.isEmpty ? "Hello" : "Hello, \(name)"
        } else if launchCount <= 3 {
            homeGreeting = name.isEmpty ? "Welcome back" : "Welcome back, \(name)"
        } else {
            let options = [
                name.isEmpty ? "Welcome back" : "Welcome back, \(name)",
                name.isEmpty ? "\(timeGreeting)" : "\(timeGreeting), \(name)",
                name.isEmpty ? "Hey there" : "Hey \(name)",
                name.isEmpty ? "Ready to create?" : "Ready to create, \(name)?"
            ]
            homeGreeting = options[launchCount % options.count]
        }
    }
    
    private func generate() {
        if canSendMessage {
            if currentThread == nil {
                let newThread = Thread()
                currentThread = newThread
                modelContext.insert(newThread)
                try? modelContext.save()
            }
            
            if let currentThread = currentThread {
                generatingThreadID = currentThread.id
                
                if currentThread.title == nil {
                    currentThread.title = prompt.components(separatedBy: "\n").first
                }
                
                Task {
                    let rawMessage = prompt
                    prompt = ""
                    #if os(iOS)
                    let attachedImageData = selectedImage.flatMap { downscaledJPEGData($0) }
                    selectedImage = nil
                    let message = rawMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && attachedImageData != nil
                        ? "Describe this image."
                        : rawMessage
                    #else
                    let attachedImageData: Data? = nil
                    let message = rawMessage
                    #endif
                    appManager.playHaptic()
                    sendMessage(Message(role: .user, content: message, thread: currentThread, imageData: attachedImageData))
                    isPromptFocused = true
                    if let modelName = appManager.currentModelName {
                        var sys = appManager.effectiveSystemPrompt
                        
                        if ModelConfiguration.getModelByName(modelName)?.modelType == .reasoning {
                            sys += " Keep your internal reasoning concise and do not overthink: answer directly."
                        }

                        let output = await llm.generate(
                            modelName: modelName,
                            thread: currentThread,
                            systemPrompt: sys,
                            thinkingEnabled: !showThinkingSwitch || appManager.thinkingModeOn
                        )
                        sendMessage(Message(role: .assistant, content: output, thread: currentThread, generatingTime: llm.thinkingTime))
                        generatingThreadID = nil
                    }
                }
            }
        }
    }
    
    private func sendMessage(_ message: Message) {
        
        if appManager.shouldPlayHaptics {
            Haptic.shared.play(.heavy)
        }
        modelContext.insert(message)
        try? modelContext.save()
    }

    @State private var newChatTriggered = false
    
    private func startNewChat() {
        prompt = ""
        currentThread = nil
        isPromptFocused = true
        newChatTriggered = false
    }
}

#if os(iOS)
struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker

        init(parent: CameraImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
#endif

#Preview {
    @FocusState var isPromptFocused: Bool
    ChatView(currentThread: .constant(nil), isPromptFocused: $isPromptFocused, showOnboarding: .constant(false), isMenuExpanded: .constant(false))
}
