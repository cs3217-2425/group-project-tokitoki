//
//  Logger.swift
//  TokiToki
//
//  Created by Wh Kang on 18/4/25.
//

// Logger.swift
import Foundation

/// A simple base logger for any subsystem.
class Logger {
    let subsystem: String

    init(subsystem: String) {
        self.subsystem = subsystem
    }

    /// Standard log.
    func log(_ message: String) {
        print("[\(subsystem)] \(message)")
    }

    /// Error log.
    func logError(_ message: String) {
        print("[\(subsystem) ERROR] \(message)")
    }
}
