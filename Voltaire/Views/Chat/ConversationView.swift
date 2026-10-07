//
//  ConversationView.swift
//  fullmoon
//
//  Created by Xavier on 16/12/2024.
//

//import MDLatex
//import MarkdownUI
import SwiftUI
import MLXLMCommon

extension TimeInterval {
    var formatted: String {
        let totalSeconds = Int(self)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60

        if minutes > 0 {
            return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
        } else {
            return "\(seconds)s"
        }
    }
}

struct MessageView: View {
    @Environment(LLMEvaluator.self) var llm
    @EnvironmentObject var appManager: AppManager
    @State private var collapsed = true
    @Binding var message: Message
    var isLive: Bool = false
    @State private var showCopied = false
    @State private var showTextSelector = false
    
    var isReasoningModel: Bool {
        guard let name = appManager.currentModelName,
              let model = ModelConfiguration.getModelByName(name) else { return false }
        return model.modelType == .reasoning || getModelTags(model).contains("Thinking")
    }
    
    var isThinking: Bool {
        !message.content.contains("</think>")
    }

    /// False when the user switched thinking off: live output is pure answer,
    /// never route it into the thinking card.
    var thinkingAllowed: Bool {
        guard let name = appManager.currentModelName,
              let model = ModelConfiguration.getModelByName(name) else { return true }
        return !model.supportsThinkingSwitch || appManager.thinkingModeOn
    }
    
    var labelColor: Color = {
        .init(UIColor.label)
    }()
    
    var bgColor: Color = {
        .init(UIColor.systemBackground)
    }()

    func processThinkingContent(_ content: String) -> (String?, String?) {
        guard let startRange = content.range(of: "<think>") else {
            // Some reasoning models omit the opening
            // <think> tag and only emit </think> — treat everything before it as thinking
            if let endRange = content.range(of: "</think>") {
                let thinking = String(content[..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                let afterThink = String(content[endRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                return (thinking.isEmpty ? nil : thinking, afterThink.isEmpty ? nil : afterThink)
            }
            // No thinking tags at all, return entire content as the second part
            return (nil, content.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        guard let endRange = content.range(of: "</think>") else {
            // No </think> tag, return content after <think> without the tag
            let thinking = String(content[startRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return (thinking, nil)
        }

        let thinking = String(content[startRange.upperBound ..< endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let afterThink = String(content[endRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)

        return (thinking, afterThink.isEmpty ? nil : afterThink)
    }

    var time: String {
        if llm.running, let elapsedTime = llm.elapsedTime {
            if isThinking {
                return elapsedTime.formatted
            }
            if let thinkingTime = llm.thinkingTime {
                return thinkingTime.formatted
            }
        }

        if let generatingTime = message.generatingTime {
            return generatingTime.formatted
        }

        return "0s"
    }
    
    var displayText: String {
        let (thinking, afterThink) = processThinkingContent(message.content)
        if let afterThink {
            return afterThink
        }
        // Unclosed thinking block: never leak raw <think> tags into copy/answer text
        if thinking != nil {
            return message.content
                .replacingOccurrences(of: "<think>", with: "")
                .replacingOccurrences(of: "</think>", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return message.content
    }
    
    var copyMenu: some View {
        Group {
            Button {
                UIPasteboard.general.string = displayText
                showCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCopied = false
                }
            } label: {
                Label("Copy Response", systemImage: "doc.on.doc")
            }
            
            Button {
                UIPasteboard.general.string = message.content
                showCopied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showCopied = false
                }
            } label: {
                Label("Copy with Thinking", systemImage: "doc.on.clipboard")
            }
            
            Button {
                showTextSelector = true
            } label: {
                Label("Select Text", systemImage: "text.cursor")
            }
        }
    }

    /// Collapsible "Thoughts" card: header row always visible, faded tail
    /// preview when collapsed, full trace when expanded.
    func thinkingCard(_ thinking: String) -> some View {
        Button {
            collapsed.toggle()
            if isThinking {
                llm.collapsed = collapsed
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Thoughts")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    if isThinking {
                        ProgressView()
                            .controlSize(.small)
                    } else {
                        Text(time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: collapsed ? "chevron.right" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                if collapsed {
                    // While live, stay calm: header + spinner only, no jumpy preview
                    if !(isLive && isThinking) {
                        Text(thinking)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .opacity(0.55)
                            .lineLimit(3)
                            .truncationMode(.head)
                            .mask(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0),
                                        .init(color: .black, location: 0.4)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .transition(.opacity)
                    }
                } else if isLive && isThinking {
                    // Cheap plain-text render while streaming; markdown once done
                    Text(thinking)
                        .foregroundStyle(.secondary)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                } else if !thinking.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    MarkdownView(thinking)
                        .foregroundStyle(.secondary)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: collapsed)
    }

    var body: some View {
        HStack {
            if message.role == .user { Spacer() }
            
            if message.role == .assistant {
                let (parsedThinking, parsedAnswer) = processThinkingContent(message.content)
                // Reasoning models can start thinking with no opening tag: while live,
                // everything before </think> is thinking — keep it out of the answer
                let streamingThinking = isLive && llm.running && isReasoningModel && thinkingAllowed && parsedThinking == nil && !message.content.contains("</think>")
                let thinking: String? = parsedThinking ?? (streamingThinking ? message.content : nil)
                let afterThink: String? = streamingThinking ? nil : parsedAnswer
                VStack(alignment: .leading, spacing: 16) {
                    if let thinking {
                        thinkingCard(thinking)
                    }
                    
                    if let afterThink {
                        //                            MDLatex.render(
                        //                                markdown: afterThink,
                        //                                theme: ThemeConfiguration(
                        //                                    backgroundColor: bgColor,
                        //                                    fontColor: labelColor,
                        //                                    fontSize: 16,
                        //                                    fontFamily: "apple-system",
                        //                                    userInteractionEnabled: true
                        //                                ),
                        //                                animation: AnimationConfiguration(isEnabled: true, chunkRenderingDuration: 0.4),
                        //                                width: geo.size.width - 24
                        //                            )
//                        Markdown(afterThink)
//                            .markdownTextStyle(\.code) {
//                                FontFamilyVariant(.monospaced)
//                                FontSize(.em(0.85))
//                                BackgroundColor(Color(.secondarySystemBackground))
//                            }
//                            .textSelection(.enabled)
                        MarkdownView(afterThink)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .contextMenu {
                    copyMenu
                }
                .sheet(isPresented: $showTextSelector) {
                    TextSelectorView(text: displayText)
                }
                .overlay {
                    if showCopied {
                        Text("Copied!")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .transition(.scale.combined(with: .opacity))
                            .zIndex(1)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showCopied)
            } else {
            VStack(alignment: .leading, spacing: 8) {
                #if os(iOS)
                if let imageData = message.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 256, maxHeight: 256)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                #endif
                MarkdownView($message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
                    .padding(.leading, 52)
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = message.content
                            showCopied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showCopied = false
                            }
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        Button {
                            showTextSelector = true
                        } label: {
                            Label("Select Text", systemImage: "text.cursor")
                        }
                    }
                    .sheet(isPresented: $showTextSelector) {
                        TextSelectorView(text: message.content)
                    }
                    .overlay {
                        if showCopied {
                            Text("Copied!")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .transition(.scale.combined(with: .opacity))
                                .zIndex(1)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: showCopied)
            }
        }
        
        .onAppear {
            // Thinking stays collapsed by default
        }
        .onChange(of: llm.elapsedTime) {
            if isThinking {
                llm.thinkingTime = llm.elapsedTime
            }
        }
        .onChange(of: isThinking) {
            if llm.running && thinkingAllowed {
                llm.isThinking = isThinking
            } else if llm.running {
                llm.isThinking = false
            }
        }
        .animation(.smooth(duration: 0.2), value: collapsed)
    }

    let platformBackgroundColor: Color = {
        return Color(UIColor.secondarySystemBackground)
    }()
}

struct ConversationView: View {
    @Environment(LLMEvaluator.self) var llm
    @EnvironmentObject var appManager: AppManager
    let thread: Thread
    let generatingThreadID: UUID?

    @State private var scrollID: String?
    @State private var scrollInterrupted = false
    
    @State private var currentMessage: Message = .init(role: .assistant, content: "")

    var body: some View {
        ScrollViewReader { scrollView in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(thread.sortedMessages) { message in
                        MessageView(message: .constant(message))
                            .padding()
                            .id(message.id.uuidString)
                    }

                    if llm.running && !llm.output.isEmpty && thread.id == generatingThreadID {
                        VStack {
                            MessageView(message: $currentMessage, isLive: true)
                        }
                        .padding()
                        .id("output")
                        .onAppear {
                            print("output appeared")
                            scrollInterrupted = false // reset interruption when a new output begins
                        }
                    }

                    Rectangle()
                        .fill(.clear)
                        .frame(height: 1)
                        .id("bottom")
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollID, anchor: .bottom)
            .scrollContentBackground(.hidden)
            .background(.clear)
            .onChange(of: llm.output) { _, _ in
                currentMessage.content = llm.output + "█"
                // auto scroll to bottom
                if !scrollInterrupted {
                    scrollView.scrollTo("bottom")
                }

                if !llm.isThinking && appManager.shouldPlayHaptics {
                    Haptic.shared.play(.light)
                }
            }
            .onChange(of: scrollID) { _, _ in
                // interrupt auto scroll to bottom if user scrolls away
                if llm.running {
                    scrollInterrupted = true
                }
            }
        }
        .defaultScrollAnchor(.bottom)
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    ConversationView(thread: Thread(), generatingThreadID: nil)
        .environment(LLMEvaluator())
        .environmentObject(AppManager())
}

struct TextSelectorView: View {
    let text: String
    @Environment(\.dismiss) var dismiss
    @State private var showCopied = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SelectableTextView(text: text)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Select Text")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SelectableTextView: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
