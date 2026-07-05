export default function Privacy() {
  return (
    <main className="legal-page">
      <div className="container">
        <a href="/" className="back-link"><i className="fa-solid fa-arrow-left"></i> Back to home</a>
        <h1>Privacy Policy</h1>
        <p className="legal-updated">Last updated: July 5, 2026</p>

        <div className="legal-section">
          <h3>1. Overview</h3>
          <p>Voltaire is designed with privacy as a core principle. The App runs entirely on your device, and your conversations, prompts, and personal data are never transmitted to external servers. This Privacy Policy explains what data the App collects, how it is used, and how it is protected.</p>
        </div>

        <div className="legal-section">
          <h3>2. Data Collection</h3>
          <p>Voltaire collects the following data locally on your device:</p>
          <ul>
            <li>Chat messages: Stored locally on your device using SwiftData</li>
            <li>Model downloads: Downloaded models are stored in your device&apos;s local storage</li>
            <li>App settings: Preferences such as theme, font settings, and haptic feedback options</li>
            <li>Usage statistics: Number of visits (stored locally only)</li>
          </ul>
        </div>

        <div className="legal-section">
          <h3>3. No Data Transmission</h3>
          <p>Voltaire does not transmit any data to external servers. All AI inference (processing of your prompts and generation of responses) occurs entirely on your device using the MLX framework. Your conversations never leave your device.</p>
        </div>

        <div className="legal-section">
          <h3>4. Model Downloads</h3>
          <p>When you download an AI model, the App connects to Hugging Face (huggingface.co) to download model files. This connection is:</p>
          <ul>
            <li>One-way: Only model files are downloaded; no personal data is sent</li>
            <li>Transparent: You initiate and control all downloads</li>
            <li>Optional: You choose which models to download</li>
          </ul>
          <p>Hugging Face may collect standard server logs (IP address, user agent) as part of serving the download, which is subject to Hugging Face&apos;s own privacy policy.</p>
        </div>

        <div className="legal-section">
          <h3>5. Local Storage</h3>
          <p>All data is stored locally on your device using:</p>
          <ul>
            <li>SwiftData: For chat messages and thread management</li>
            <li>AppStorage (UserDefaults): For app settings and preferences</li>
            <li>File System: For downloaded model files</li>
          </ul>
          <p>You can delete all data at any time through the App&apos;s settings (Reset App Completely) or by uninstalling the App.</p>
        </div>

        <div className="legal-section">
          <h3>6. No Analytics or Tracking</h3>
          <p>Voltaire does not use any analytics services, tracking tools, advertising SDKs, or telemetry. We do not collect any information about how you use the App, what prompts you enter, or what responses are generated.</p>
        </div>

        <div className="legal-section">
          <h3>7. No Account Required</h3>
          <p>Voltaire does not require you to create an account, provide an email address, or log in. The App is fully functional without any account or identity verification.</p>
        </div>

        <div className="legal-section">
          <h3>8. Children&apos;s Privacy</h3>
          <p>Voltaire does not knowingly collect any personal information from children under the age of 13. The App does not require any personal information to function.</p>
        </div>

        <div className="legal-section">
          <h3>9. Data Deletion</h3>
          <p>You can delete all your data at any time by:</p>
          <ul>
            <li>Using the &quot;Reset App Completely&quot; option in Settings</li>
            <li>Deleting individual chats from the chat list</li>
            <li>Uninstalling the App from your device</li>
          </ul>
          <p>Upon deletion, all locally stored data is permanently removed from your device.</p>
        </div>

        <div className="legal-section">
          <h3>10. Changes to This Policy</h3>
          <p>We may update this Privacy Policy from time to time. Changes will be reflected in the &quot;Last updated&quot; date above. Continued use of the App after changes constitutes acceptance of the updated policy.</p>
        </div>

        <div className="legal-section">
          <h3>11. Contact</h3>
          <p>If you have any questions about this Privacy Policy or our privacy practices, please contact us through the App&apos;s support channels.</p>
        </div>
      </div>
    </main>
  );
}
