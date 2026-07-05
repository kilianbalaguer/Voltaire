//
//  ChatsListView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/5/24.
//

import StoreKit
import SwiftData
import SwiftUI

struct ChatsListView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.dismiss) var dismiss
    @Binding var showChats: Bool
    @Binding var currentThread: Thread?
    @FocusState.Binding var isPromptFocused: Bool
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Thread.timestamp, order: .reverse) var threads: [Thread]
    @State var search = ""
    @State var selection: Thread?
    @State private var showNoModelAlert = false
    
    @State var llm = LLMEvaluator()
    
    @Environment(\.requestReview) private var requestReview
    
    @ViewBuilder var newItem: some View {
        // removed; use bottom bar toolbar instead
        EmptyView()
    }
    
    @ViewBuilder var chats: some View {
        Group {
            ForEach(filteredThreads, id: \.id) { thread in
                VStack(alignment: .leading) {
                    Text(thread.title ?? "Untitled Chat")
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(thread.timestamp.formatted())")
                    }
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                }
                .contextMenu {
                    Button("Rename", systemImage: "pencil") {
                        UIApplication.shared.alertWithTextField(title: "Rename Chat", body: "", placeholder: (thread.title ?? ""), onOK: {new in
                            if !new.isEmpty {
                                thread.title = new
                            }
                        })
                    }
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        deleteThread(thread)
                    }
                } preview: {
                    ChatView(currentThread: .constant(thread), isPromptFocused: $isPromptFocused, showChats: .constant(false), showSettings: .constant(false), showOnboarding: .constant(false), isPreview: true)
                        .environment(llm)
                        .environmentObject(appManager)
                }
                .onTapGesture {
                    showChats = false
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selection = thread
                    }
                }
            }
            .onDelete(perform: deleteThreads)
        }
    }
    
    @ViewBuilder var list: some View {
        List(selection: $selection) {
            chats
        }
        .listStyle(.insetGrouped)
    }
    
    
    var body: some View {
        Group {
            ZStack {
                list
                    .onChange(of: selection) {
                        setCurrentThread(selection)
                    }
                if filteredThreads.count == 0 {
                    ContentUnavailableView {
                        Label(threads.count == 0 ? "No Chats" : "No results", systemImage: "message")
                    }
                }
            }
            .modifier(CustomNavTitle(title: "Conversations"))
            .searchable(text: $search)
            .toolbar {
                if #available(iOS 18.0, *) {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Button("New Chat", systemImage: "plus") {
                            if appManager.hasInstalledModels {
                                setCurrentThread(nil)
                            } else {
                                showNoModelAlert = true
                            }
                        }
                        .buttonStyle(.glassProminent)
                        .disabled(!appManager.hasInstalledModels)
                    }
                } else {
                    ToolbarItem(placement: .bottomBar) {
                        Button("New Chat", systemImage: "plus") {
                            if appManager.hasInstalledModels {
                                setCurrentThread(nil)
                            } else {
                                showNoModelAlert = true
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!appManager.hasInstalledModels)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showChats = false }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .alert("No Model Installed", isPresented: $showNoModelAlert) {
                Button("Install Model") {
                    showChats = false
                    // Open settings to install model
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please install a model first to start a new chat.")
            }
        }
        .tint(appManager.appTintColor.getColor())
        
        .if(appManager.userInterfaceIdiom != .phone) { view in
            NavigationStack {
                view
            }
        }
        .if(appManager.userInterfaceIdiom == .phone) { view in
            view
                .onChange(of: currentThread) {
                    selection = currentThread
                }
        }
    }

    var filteredThreads: [Thread] {
        threads.filter { thread in
            search.isEmpty || thread.messages.contains { message in
                message.content.localizedCaseInsensitiveContains(search)
            }
        }
    }
    
    func requestReviewIfAppropriate() {
        //        if appManager.numberOfVisits - appManager.numberOfVisitsOfLastRequest >= 5 {
        //            requestReview() // can only be prompted if the user hasn't given a review in the last year, so it will prompt again when apple deems appropriate
        //            appManager.numberOfVisitsOfLastRequest = appManager.numberOfVisits
        //        }
    }
    
    private func deleteThreads(at offsets: IndexSet) {
        for offset in offsets {
            let thread = threads[offset]
            
            if let currentThread = currentThread {
                if currentThread.id == thread.id {
                    setCurrentThread(nil)
                }
            }
            
            // Adding a delay fixes a crash on iOS following a deletion
            let delay = appManager.userInterfaceIdiom == .phone ? 1.0 : 0.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                modelContext.delete(thread)
            }
        }
    }
    
    private func deleteThread(_ thread: Thread) {
        if let currentThread = currentThread {
            if currentThread.id == thread.id {
                setCurrentThread(nil)
            }
        }
        modelContext.delete(thread)
    }
    
    private func setCurrentThread(_ thread: Thread? = nil) {
        currentThread = thread
        showChats = false
        isPromptFocused = true
        dismiss()
        if appManager.shouldPlayHaptics {
            Haptic.shared.play(.light)
        }
    }
}

#Preview {
    @FocusState var isPromptFocused: Bool
    ChatsListView(showChats: .constant(false), currentThread: .constant(nil), isPromptFocused: $isPromptFocused)
}
