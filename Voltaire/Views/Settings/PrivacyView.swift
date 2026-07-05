//
//  PrivacyView.swift
//  Voltaire
//

import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Privacy Policy")
                    .font(.title2.weight(.semibold))
                
                Text("Last updated: July 5, 2026")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Group {
                    section("1. Overview", content: """
                    Voltaire is designed with privacy as a core principle. The App runs entirely on your device, and your conversations, prompts, and personal data are never transmitted to external servers. This Privacy Policy explains what data the App collects, how it is used, and how it is protected.
                    """)
                    
                    section("2. Data Collection", content: """
                    Voltaire collects the following data locally on your device:
                    - Chat messages: Stored locally on your device using SwiftData
                    - Model downloads: Downloaded models are stored in your device's local storage
                    - App settings: Preferences such as theme, font settings, and haptic feedback options
                    - Usage statistics: Number of visits (stored locally only)
                    """)
                    
                    section("3. No Data Transmission", content: """
                    Voltaire does not transmit any data to external servers. All AI inference (processing of your prompts and generation of responses) occurs entirely on your device using the MLX framework. Your conversations never leave your device.
                    """)
                    
                    section("4. Model Downloads", content: """
                    When you download an AI model, the App connects to Hugging Face (huggingface.co) to download model files. This connection is:
                    - One-way: Only model files are downloaded; no personal data is sent
                    - Transparent: You initiate and control all downloads
                    - Optional: You choose which models to download
                    
                    Hugging Face may collect standard server logs (IP address, user agent) as part of serving the download, which is subject to Hugging Face's own privacy policy.
                    """)
                    
                    section("5. Local Storage", content: """
                    All data is stored locally on your device using:
                    - SwiftData: For chat messages and thread management
                    - AppStorage (UserDefaults): For app settings and preferences
                    - File System: For downloaded model files
                    
                    You can delete all data at any time through the App's settings (Reset App Completely) or by uninstalling the App.
                    """)
                    
                    section("6. No Analytics or Tracking", content: """
                    Voltaire does not use any analytics services, tracking tools, advertising SDKs, or telemetry. We do not collect any information about how you use the App, what prompts you enter, or what responses are generated.
                    """)
                    
                    section("7. No Account Required", content: """
                    Voltaire does not require you to create an account, provide an email address, or log in. The App is fully functional without any account or identity verification.
                    """)
                    
                    section("8. Children's Privacy", content: """
                    Voltaire does not knowingly collect any personal information from children under the age of 13. The App does not require any personal information to function.
                    """)
                    
                    section("9. Data Deletion", content: """
                    You can delete all your data at any time by:
                    - Using the \"Reset App Completely\" option in Settings
                    - Deleting individual chats from the chat list
                    - Uninstalling the App from your device
                    
                    Upon deletion, all locally stored data is permanently removed from your device.
                    """)
                    
                    section("10. Changes to This Policy", content: """
                    We may update this Privacy Policy from time to time. Changes will be reflected in the \"Last updated\" date above. Continued use of the App after changes constitutes acceptance of the updated policy.
                    """)
                    
                    section("11. Contact", content: """
                    If you have any questions about this Privacy Policy or our privacy practices, please contact us through the App's support channels.
                    """)
                }
            }
            .padding()
        }
        .modifier(CustomNavTitle(title: "Privacy Policy"))
        .navigationPopGestureDisabled(true)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func section(_ title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    PrivacyView()
}
