import SwiftUI
import Combine

struct TypingGreetingView: View {
    let texts: [String]
    var typingSpeed: Double = 0.06
    var backspaceSpeed: Double = 0.03
    var pauseAfterType: Double = 2.0
    var pauseAfterDelete: Double = 0.5
    var isActive: Bool = true
    
    @State private var displayText = ""
    @State private var usedIndices: Set<Int> = []
    @State private var currentIndex = 0
    @State private var timer: AnyCancellable?
    @State private var phase: Phase = .typing
    @State private var cursorBlinkOn = true
    @State private var isRunning = false
    
    let cursorTimer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    enum Phase {
        case typing
        case pauseAfterType
        case backspacing
        case pauseAfterDelete
    }
    
    var showCursor: Bool {
        switch phase {
        case .typing, .backspacing:
            return true
        case .pauseAfterType, .pauseAfterDelete:
            return cursorBlinkOn
        }
    }
    
    var body: some View {
        Text(displayText + (showCursor ? "|" : " "))
            .font(.system(size: 34, weight: .regular, design: .monospaced))
            .foregroundStyle(.black.opacity(0.3))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .onAppear {
                if isActive {
                    isRunning = true
                    startTyping()
                }
            }
            .onChange(of: isActive) { _, active in
                if active {
                    isRunning = true
                    startTyping()
                } else {
                    stopAll()
                }
            }
            .onReceive(cursorTimer) { _ in
                guard isRunning else { return }
                if phase == .pauseAfterType || phase == .pauseAfterDelete {
                    cursorBlinkOn.toggle()
                }
            }
            .onDisappear {
                stopAll()
            }
    }
    
    private func stopAll() {
        isRunning = false
        timer?.cancel()
        timer = nil
        displayText = ""
    }
    
    private func startTyping() {
        displayText = ""
        phase = .typing
        pickRandomIndex()
        timer = Timer.publish(every: typingSpeed, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                typeNextCharacter()
            }
    }
    
    private func pickRandomIndex() {
        if usedIndices.count >= texts.count {
            usedIndices.removeAll()
        }
        var newIndex: Int
        repeat {
            newIndex = Int.random(in: 0..<texts.count)
        } while usedIndices.contains(newIndex)
        usedIndices.insert(newIndex)
        currentIndex = newIndex
    }
    
    private func typeNextCharacter() {
        guard isRunning else { return }
        let currentText = texts[currentIndex % texts.count]
        if displayText.count < currentText.count {
            let index = currentText.index(currentText.startIndex, offsetBy: displayText.count)
            displayText.append(currentText[index])
            Haptic.shared.play(.light)
        } else {
            timer?.cancel()
            phase = .pauseAfterType
            cursorBlinkOn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseAfterType) {
                guard isRunning else { return }
                startBackspacing()
            }
        }
    }
    
    private func startBackspacing() {
        phase = .backspacing
        timer = Timer.publish(every: backspaceSpeed, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                backspaceNextCharacter()
            }
    }
    
    private func backspaceNextCharacter() {
        guard isRunning else { return }
        if !displayText.isEmpty {
            displayText.removeLast()
            Haptic.shared.play(.light)
        } else {
            timer?.cancel()
            phase = .pauseAfterDelete
            cursorBlinkOn = true
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseAfterDelete) {
                guard isRunning else { return }
                startTyping()
            }
        }
    }
}
