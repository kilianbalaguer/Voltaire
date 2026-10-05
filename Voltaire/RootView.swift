//
//  ContentView.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import SwiftData
import SwiftUI

enum MainContent: Equatable {
    case chat
    case settings
}

struct RootView: View {
    @EnvironmentObject var appManager: AppManager
    @Environment(\.modelContext) var modelContext
    @Environment(LLMEvaluator.self) var llm
    @State var showOnboarding = false
    @State var isMenuExpanded = false
    @State var currentThread: Thread?
    @State var showSettings = false
    @FocusState var isPromptFocused: Bool

    var body: some View {
        CustomSideMenu(isEnabled: true, isExpanded: $isMenuExpanded) { progress in
            SideMenuContentView(
                currentThread: $currentThread,
                isMenuExpanded: $isMenuExpanded,
                isPromptFocused: $isPromptFocused,
                onSelectSettings: {
                    showSettings = true
                },
                onOpenChat: {
                    isMenuExpanded = false
                }
            )
        } content: { progress in
            ChatView(
                currentThread: $currentThread,
                isPromptFocused: $isPromptFocused,
                showOnboarding: $showOnboarding,
                isMenuExpanded: isMenuExpanded,
                menuProgress: progress
            )
        }
        .environmentObject(appManager)
        .environment(llm)
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView(
                currentThread: $currentThread,
                onDismiss: {
                    showSettings = false
                }
            )
            .environmentObject(appManager)
            .environment(llm)
        }
        .onChange(of: isMenuExpanded) { _, expanded in
            if expanded {
                isPromptFocused = false
            }
        }
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
