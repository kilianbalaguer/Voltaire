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
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .id(appRestartID)
                .modelContainer(for: [Thread.self, Message.self])
                .environmentObject(appManager)
                .environment(llm)
                .environment(DeviceStat())
                .onReceive(NotificationCenter.default.publisher(for: .restartApp)) { _ in
                    appRestartID = UUID()
                }
        }
    }
}
