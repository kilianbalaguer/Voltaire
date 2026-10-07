//
//  SideMenuContentView.swift
//  Voltaire
//

import SwiftData
import SwiftUI

struct SideMenuContentView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Environment(LLMEvaluator.self) var llm
    @Environment(\.colorScheme) private var colorScheme
    @Binding var currentThread: Thread?
    @Binding var isMenuExpanded: Bool
    @FocusState.Binding var isPromptFocused: Bool
    var onSelectSettings: (() -> Void)? = nil
    var onOpenChat: (() -> Void)? = nil
    @Query(sort: \Thread.timestamp, order: .reverse) private var threads: [Thread]
    @State private var showNoModelAlert = false
    @State private var isSearching = false
    @State private var searchText = ""

    private var filteredThreads: [Thread] {
        guard isSearching, !searchText.isEmpty else { return threads }
        return threads.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.top, 8)

                if isSearching {
                    searchField
                        .padding(.top, 12)
                }

                chatList
                    .padding(.top, 16)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .background {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
            .safeAreaInset(edge: .bottom, alignment: .center, spacing: 0) {
                bottomBar
                    .padding(.horizontal, 13)
                    .padding(.bottom, 13)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .tint(appManager.appTintColor.getColor())
        .onChange(of: isMenuExpanded) { _, expanded in
            if !expanded {
                isSearching = false
                searchText = ""
            }
        }
        .alert("No Model Installed", isPresented: $showNoModelAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please install a model first to start a new chat.")
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Voltaire")
                    .font(.title2.bold())
                Text("Conversations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            Button {
                if appManager.shouldPlayHaptics {
                    Haptic.shared.play(.light)
                }
                withAnimation(.easeInOut(duration: 0.2)) {
                    isSearching.toggle()
                    if !isSearching {
                        searchText = ""
                    }
                }
            } label: {
                Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Search chats")
        }
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.secondary)

            TextField("Search chats", text: $searchText)
                .textFieldStyle(.plain)
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }

    private var bottomBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            Button {
                startNewChat()
            } label: {
                Label("New Chat", systemImage: "square.and.pencil")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 18)
                    .frame(height: 48)
                    .foregroundStyle(newChatForeground)
                    .background(
                        Capsule(style: .continuous)
                            .fill(newChatBackground)
                    )
            }
            .buttonStyle(.plain)
            .disabled(!appManager.hasInstalledModels)
            .opacity(appManager.hasInstalledModels ? 1 : 0.5)

            Spacer(minLength: 0)

            Button {
                if appManager.shouldPlayHaptics {
                    Haptic.shared.play(.light)
                }
                onSelectSettings?()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 48, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
    }

    /// Light: black pill / white text — Dark: white pill / black text
    private var newChatBackground: Color {
        colorScheme == .dark ? .white : .black
    }

    private var newChatForeground: Color {
        colorScheme == .dark ? .black : .white
    }

    @ViewBuilder
    private var chatList: some View {
        if filteredThreads.isEmpty {
            ContentUnavailableView {
                Label(isSearching ? "No Results" : "No Chats", systemImage: isSearching ? "magnifyingglass" : "message")
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(filteredThreads, id: \.id) { thread in
                        Button {
                            selectThread(thread)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(thread.title ?? "Untitled Chat")
                                    .lineLimit(1)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(thread.timestamp.formatted())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 11)
                            .padding(.horizontal, 14)
                        }
                        .buttonStyle(SideMenuChatRowStyle(isSelected: currentThread?.id == thread.id))
                        .contextMenu {
                            Button("Rename", systemImage: "pencil") {
                                UIApplication.shared.alertWithTextField(
                                    title: "Rename Chat",
                                    body: "",
                                    placeholder: (thread.title ?? ""),
                                    onOK: { new in
                                        if !new.isEmpty {
                                            thread.title = new
                                        }
                                    }
                                )
                            }
                            Button("Delete", systemImage: "trash", role: .destructive) {
                                deleteThread(thread)
                            }
                        }
                    }
                }
                .padding(.horizontal, 2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func selectThread(_ thread: Thread) {
        currentThread = thread
        isPromptFocused = true
        onOpenChat?()
        closeMenu()
    }

    private func startNewChat() {
        guard appManager.hasInstalledModels else {
            showNoModelAlert = true
            return
        }
        currentThread = nil
        isPromptFocused = true
        onOpenChat?()
        closeMenu()
    }

    private func deleteThread(_ thread: Thread) {
        if currentThread?.id == thread.id {
            currentThread = nil
        }
        modelContext.delete(thread)
        try? modelContext.save()
    }

    private func closeMenu() {
        if appManager.shouldPlayHaptics {
            Haptic.shared.play(.light)
        }
        isSearching = false
        searchText = ""
        isMenuExpanded = false
    }
}

#Preview {
    @FocusState var isPromptFocused: Bool
    SideMenuContentView(
        currentThread: .constant(nil),
        isMenuExpanded: .constant(false),
        isPromptFocused: $isPromptFocused
    )
    .environmentObject(AppManager())
    .environment(LLMEvaluator())
    .modelContainer(for: [Thread.self, Message.self], inMemory: true)
}

/// Pill highlight for selected + pressed chat rows — matches full row size
struct SideMenuChatRowStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.thinMaterial)
                    .opacity(isSelected || configuration.isPressed ? 1 : 0)
            }
    }
}
