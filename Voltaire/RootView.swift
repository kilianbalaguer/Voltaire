//
//  ContentView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import SwiftData
import SwiftUI

struct RootView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Environment(LLMEvaluator.self) var llm
    @State var showOnboarding = false
    @State var showSettings = false
    @State var showChats = false
    @State var currentThread: Thread?
    @FocusState var isPromptFocused: Bool
    

    var body: some View {
        Group {
            if appManager.userInterfaceIdiom == .phone {
                    ChatView(currentThread: $currentThread, isPromptFocused: $isPromptFocused, showChats: $showChats, showSettings: $showSettings, showOnboarding: $showOnboarding)
                    .onChange(of: showChats) {
                        if showChats {
                            isPromptFocused = false
                        }
                    }
            } else {
                // iPad
                NavigationSplitView {
                    ChatsListView(showChats: $showChats, currentThread: $currentThread, isPromptFocused: $isPromptFocused)
                } detail: {
                ChatView(currentThread: $currentThread, isPromptFocused: $isPromptFocused, showChats: $showChats, showSettings: $showSettings, showOnboarding: $showOnboarding)
                }
            }
        }
        .environmentObject(appManager)
        .environment(llm)
        .task {
            if !appManager.hasSeenOnboarding {
                showOnboarding.toggle()
            } else {
                // load the model
                if let modelName = appManager.currentModelName {
                    _ = try? await llm.load(modelName: modelName)
                }
            }
        }
//        .if(appManager.userInterfaceIdiom == .phone) { view in
//            view
//                .gesture(
//                    DragGesture()
//                        .onChanged { gesture in
//                            if !showChats && gesture.startLocation.x < 20 && gesture.translation.width > 100 {
//                                appManager.playHaptic()
//                                showChats = true
//                            }
//                        }
//                )
//        }
        .sheet(isPresented: $showChats) {
            NavigationStack {
                ChatsListView(showChats: $showChats, currentThread: $currentThread, isPromptFocused: $isPromptFocused)
                    .environmentObject(appManager)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.hidden)
            .interactiveDismissDisabled(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(currentThread: $currentThread)
                .environmentObject(appManager)
                .environment(llm)
                .presentationDragIndicator(.hidden)
                .presentationDetents([.large])
                .interactiveDismissDisabled(true)
                .if(appManager.userInterfaceIdiom == .phone) { view in
                    view.presentationDetents([.large])
                }
        }
        .sheet(isPresented: $showOnboarding, onDismiss: dismissOnboarding) {
            OnboardingView(showOnboarding: $showOnboarding)
                .environment(llm)
                .interactiveDismissDisabled(true)
        }
        .tint(appManager.appTintColor.getColor())
        .onAppear {
            appManager.incrementNumberOfVisits()
            cleanupOrphanedBlobs()
        }
    }
    
    func dismissOnboarding() {
        isPromptFocused = true
    }
}

struct CustomNavTitle: ViewModifier {
    var title: String
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .font(.headline)
                }
            }
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    RootView()
}
