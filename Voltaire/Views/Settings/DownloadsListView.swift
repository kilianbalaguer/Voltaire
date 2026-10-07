//
//  DownloadsListView.swift
//  Voltaire
//

import SwiftUI
import MLXLMCommon

struct DownloadsListView: View {
    @State private var downloadManager = DownloadManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            if downloadManager.activeNames.isEmpty && downloadManager.recent.isEmpty {
                Section {
                    Text("No downloads yet. Pick a model to download it for offline use.")
                        .foregroundStyle(.secondary)
                }
            }

            if !downloadManager.activeNames.isEmpty {
                Section("Downloading") {
                    ForEach(downloadManager.activeNames, id: \.self) { name in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(ModelConfiguration.getModelByName(name)?.familyName ?? name)
                                    .font(.headline)
                                Spacer()
                                if let eta = downloadManager.eta(for: name) {
                                    Text(eta)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Button {
                                    downloadManager.cancelDownload(named: name)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            ProgressView(value: downloadManager.progress(for: name))
                            Text("\(Int(downloadManager.progress(for: name) * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            if !downloadManager.recent.isEmpty {
                Section("Recent") {
                    ForEach(downloadManager.recent) { record in
                        HStack {
                            Image(systemName: record.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(record.success ? .green : .secondary)
                            Text(ModelConfiguration.getModelByName(record.modelName)?.familyName ?? record.modelName)
                            Spacer()
                            Text(record.finishedAt.formatted(date: .omitted, time: .shortened))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
        }
    }
}
