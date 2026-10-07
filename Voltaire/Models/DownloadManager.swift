//
//  DownloadManager.swift
//  Voltaire
//
//  Owns model downloads so they keep running when you leave the
//  model screens, and stay alive briefly when the app backgrounds.
//

import Foundation
import SwiftUI
import UIKit
import MLXLMCommon

struct DownloadRecord: Identifiable {
    let id = UUID()
    let modelName: String
    let finishedAt: Date
    let success: Bool
}

@MainActor
@Observable
final class DownloadManager {
    static let shared = DownloadManager()

    private(set) var activeProgress: [String: Double] = [:]
    private(set) var activeETAs: [String: String] = [:]
    private(set) var recent: [DownloadRecord] = []

    private var tasks: [String: Task<Void, Never>] = [:]
    private var startTimes: [String: Date] = [:]
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    var activeCount: Int { tasks.count }

    var activeNames: [String] { tasks.keys.sorted() }

    func isDownloading(_ modelName: String) -> Bool {
        tasks[modelName] != nil
    }

    func progress(for modelName: String) -> Double {
        activeProgress[modelName] ?? 0
    }

    func eta(for modelName: String) -> String? {
        activeETAs[modelName]
    }

    func startDownload(model: ModelConfiguration, llm: LLMEvaluator, appManager: AppManager) {
        guard tasks[model.name] == nil else { return }
        activeProgress[model.name] = 0
        startTimes[model.name] = Date()
        beginBackgroundTaskIfNeeded()

        let task = Task {
            let progressTask = Task {
                while !Task.isCancelled {
                    let currentProgress = llm.progress
                    self.activeProgress[model.name] = currentProgress

                    if let startTime = self.startTimes[model.name],
                       let modelSize = model.modelSize,
                       currentProgress > 0.01 {
                        let elapsed = Date().timeIntervalSince(startTime)
                        let bytesTotal = NSDecimalNumber(decimal: modelSize).doubleValue * 1024 * 1024 * 1024
                        let bytesDownloaded = bytesTotal * currentProgress
                        let speed = bytesDownloaded / elapsed
                        if speed > 0 {
                            let remaining = bytesTotal - bytesDownloaded
                            let etaSeconds = remaining / speed
                            if etaSeconds < 60 {
                                self.activeETAs[model.name] = "\(Int(etaSeconds))s"
                            } else if etaSeconds < 3600 {
                                self.activeETAs[model.name] = "\(Int(etaSeconds / 60))m \(Int(etaSeconds.truncatingRemainder(dividingBy: 60)))s"
                            } else {
                                self.activeETAs[model.name] = "\(Int(etaSeconds / 3600))h \(Int((etaSeconds.truncatingRemainder(dividingBy: 3600)) / 60))m"
                            }
                        }
                    }

                    if currentProgress >= 1.0 { break }
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
            }

            await llm.switchModel(model)
            progressTask.cancel()

            let wasCancelled = Task.isCancelled
            if !wasCancelled {
                appManager.addInstalledModel(model.name)
                appManager.currentModelName = model.name
            }

            self.finishDownload(named: model.name, success: !wasCancelled)
        }

        tasks[model.name] = task
    }

    func cancelDownload(named modelName: String) {
        guard let task = tasks[modelName] else { return }
        task.cancel()
        finishDownload(named: modelName, success: false)
    }

    private func finishDownload(named modelName: String, success: Bool) {
        tasks.removeValue(forKey: modelName)
        activeProgress.removeValue(forKey: modelName)
        activeETAs.removeValue(forKey: modelName)
        startTimes.removeValue(forKey: modelName)
        recent.insert(DownloadRecord(modelName: modelName, finishedAt: Date(), success: success), at: 0)
        if recent.count > 20 {
            recent = Array(recent.prefix(20))
        }
        endBackgroundTaskIfNeeded()
    }

    private func beginBackgroundTaskIfNeeded() {
        guard backgroundTaskID == .invalid else { return }
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "VoltaireModelDownload") { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                UIApplication.shared.endBackgroundTask(self.backgroundTaskID)
                self.backgroundTaskID = .invalid
            }
        }
    }

    private func endBackgroundTaskIfNeeded() {
        guard tasks.isEmpty, backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}
