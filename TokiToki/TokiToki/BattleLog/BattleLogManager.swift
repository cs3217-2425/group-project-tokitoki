//
//  BattleLogManager.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

class BattleLogManager {
    private var logEntries: [LogEntry] = []
    private let maxVisibleEntries = 4
    weak var observer: BattleLogObserver?

    func addLogMessage(_ message: String) {
        guard !message.isEmpty else {
            return
        }

        logEntries.append(LogEntry(message: message, opacity: 1.0))

        updateOpacityValues()

        observer?.update(logEntries: logEntries)
    }

    private func updateOpacityValues() {
        if logEntries.count > maxVisibleEntries {
            logEntries = Array(logEntries.suffix(maxVisibleEntries))
        }

        // Update opacity based on position (newer = more opaque)
        for i in 0..<logEntries.count {
            // Calculate opacity: newest (last in array) has 1.0, oldest approaches 0.0
            let opacityStep = 1.0 / CGFloat(maxVisibleEntries)
            let position = i // Reverse index (newest = highest)
            logEntries[i].opacity = logEntries.count >= maxVisibleEntries
            ? max(0.5, CGFloat(position + 1) * opacityStep) : 1.0
        }
    }

    func getLogMessages() -> [String] {
        logEntries.map { $0.message }
    }

    func clearLogs() {
        logEntries = []
        observer?.update(logEntries: [])
    }
}

struct LogEntry {
    let message: String
    var opacity: CGFloat // 1.0 = fully visible, 0.0 = invisible
}
