//
//  VoltaireApp.swift
//  fullmoon
//
//  Created by Jordan Singer on 10/4/24.
//

import SwiftUI
import MLXLLM

extension Notification.Name {
    static let restartApp = Notification.Name("restartApp")
}

@main
struct VoltaireApp: App {
    @StateObject var appManager = AppManager()
    @State var llm = LLMEvaluator()
    @State private var appRestartID = UUID()
    @State private var showSplash: Bool

    init() {
        // First launch skips the app splash — onboarding plays its own intro
        _showSplash = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .id(appRestartID)
                    .modelContainer(for: [Thread.self, Message.self])
                    .environmentObject(appManager)
                    .environment(llm)
                    .environment(DeviceStat())
                    .background(Color(.systemBackground))
                    .onReceive(NotificationCenter.default.publisher(for: .restartApp)) { _ in
                        appRestartID = UUID()
                    }

                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.35)) {
                            showSplash = false
                        }
                        appManager.splashComplete = true
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
