//
//  ChatView.swift
//  fullmoon
//
//  Created by Jordan Singer on 12/3/24.
//

import SwiftUI
import MLXLMCommon
import Shimmer

struct ChatView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Binding var currentThread: Thread?
    @Environment(LLMEvaluator.self) var llm
    @Namespace var bottomID
    @State var showModelPicker = false
    @State var prompt = ""
    @FocusState.Binding var isPromptFocused: Bool
    @Binding var showChats: Bool
    @Binding var showSettings: Bool
    @Binding var showOnboarding: Bool
    
    @State var thinkingTime: TimeInterval?
    
    @State private var generatingThreadID: UUID?
    @State private var showNoModelAlert = false
    @State private var showFeatureWarning = false
    @State private var blobPhase: CGFloat = 0
    @State private var homeGreeting = ""
    @State private var gradientFlipped = false
    @AppStorage("launchCount") private var launchCount = 0
    
    public var isPreview = false
    
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
    
    var chatInput: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Menu {
                Button {
                    showFeatureWarning = true
                } label: {
                    Label("Attach File", systemImage: "doc")
                }
                .disabled(false)
                
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
        .disabled((isPromptEmpty && !llm.running) || (llm.running && llm.cancelled))
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
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        TypingGreetingView(
                            texts: greetingTexts,
                            typingSpeed: 0.06,
                            backspaceSpeed: 0.03,
                            pauseAfterType: 2.5,
                            pauseAfterDelete: 0.5,
                            isActive: currentThread == nil && !showSettings && !showChats && !showModelPicker && !showOnboarding
                        )
                        .padding(.horizontal, 24)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.top, 170)
                        
                        Spacer()
                    }
                    .background {
                        ZStack {
                            // Animated radial blob 1
                            RadialGradient(
                                colors: [
                                    Color(red: 0.133, green: 0.827, blue: 0.933).opacity(0.7),
                                    .clear
                                ],
                                center: UnitPoint(
                                    x: 0.8 + 0.15 * sin(blobPhase),
                                    y: 0.15 + 0.1 * cos(blobPhase * 0.7)
                                ),
                                startRadius: 0,
                                endRadius: 400
                            )
                            
                            // Animated radial blob 2
                            RadialGradient(
                                colors: [
                                    Color(red: 0.290, green: 0.871, blue: 0.502).opacity(0.5),
                                    .clear
                                ],
                                center: UnitPoint(
                                    x: 0.7 + 0.1 * cos(blobPhase * 0.8),
                                    y: 0.25 + 0.15 * sin(blobPhase * 0.6)
                                ),
                                startRadius: 0,
                                endRadius: 350
                            )
                            
                            // Static dark blue base
                            RadialGradient(
                                colors: [
                                    Color(red: 0.047, green: 0.290, blue: 0.745).opacity(0.4),
                                    .clear
                                ],
                                center: .topTrailing,
                                startRadius: 0,
                                endRadius: 500
                            )
                        }
                    }
                    .onAppear {
                        generateGreeting()
                        withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                            blobPhase = .pi
                        }
                        gradientFlipped = true
                    }
                    .transition(.opacity)
                    .ignoresSafeArea(edges: .all)
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentThread != nil)
            .onTapGesture {
                isPromptFocused = false
            }
            .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
                if !isPreview {
                    VStack(spacing: 0) {
                        if case .loading = llm.loadState {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .tint(.black)
                                Text("Loading model...")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.black)
                                    .shimmering()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassEffect()
                            .padding(.bottom, 6)
                        }
                        
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
            .sheet(isPresented: $showModelPicker) {
                NavigationStack {
                    ModelsSettingsView()
                        .environmentObject(appManager)
                        .environment(llm)
                        .interactiveDismissDisabled(true)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button(action: { showModelPicker = false }) {
                                    Image(systemName: "xmark")
                                }
                            }
                        }
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
                    if appManager.userInterfaceIdiom == .phone {
                        ToolbarItem(placement: .principal) {
                            modelPickerMenu
                        }
                        
                        ToolbarItem(placement: .topBarLeading) {
                            HStack(spacing: 8) {
                                Button(action: {
                                    if appManager.shouldPlayHaptics {
                                        Haptic.shared.play(.light)
                                    }
                                    showSettings.toggle()
                                }) {
                                    Image(systemName: "gear")
                                }

                                Spacer().frame(width: 6)

                                Button(action: {
//                                appManager.playHaptic()
                                    showChats.toggle()
                                }) {
                                    Image(systemName: "message")
                                        .contentTransition(.symbolEffect(.replace))
                                }
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                if appManager.hasInstalledModels {
                                    startNewChat()
                                } else {
                                    showNoModelAlert = true
                                }
                            }) {
                                Image(systemName: "square.and.pencil")
                            }
                            .disabled(!appManager.hasInstalledModels)
                            .foregroundStyle(appManager.hasInstalledModels ? .primary : .tertiary)
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                modelPickerMenu
                                Button(action: {
                                    if appManager.shouldPlayHaptics {
                                        Haptic.shared.play(.light)
                                    }
                                    appManager.playHaptic()
                                    showSettings.toggle()
                                }) {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                    }
                }
            }
        }
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
        if !isPromptEmpty {
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
                    let message = prompt
                    prompt = ""
                    appManager.playHaptic()
                    sendMessage(Message(role: .user, content: message, thread: currentThread))
                    isPromptFocused = true
                    if let modelName = appManager.currentModelName {
                        var sys = appManager.systemPrompt
                        
//                        if ModelConfiguration.getModelByName(modelName)?.modelType == .reasoning {
//                            sys += " You are also an advanced AI model, capable of reasoning and understanding complex concepts. However, your current environment has limited compute resources. Use your reasoning ability sparingly, and when you do, make sure to keep the language within your internal dialog concise and don't overthink, as to not exceed your token limit."
//                        }
                        
                        print(sys)
                        
                        let output = await llm.generate(modelName: modelName, thread: currentThread, systemPrompt: sys)
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

    private func startNewChat() {
        prompt = ""
        currentThread = nil
        isPromptFocused = true
    }
}

#Preview {
    @FocusState var isPromptFocused: Bool
    ChatView(currentThread: .constant(nil), isPromptFocused: $isPromptFocused, showChats: .constant(false), showSettings: .constant(false), showOnboarding: .constant(false))
}
