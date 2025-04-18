//
//  JsonPersistenceManagerLogger.swift
//  TokiToki
//
//  Created by Wh Kang on 18/4/25.
//


// JsonPersistenceManagerLogger.swift
import Foundation

/// Logger dedicated to JsonPersistenceManager events.
class JsonPersistenceManagerLogger: Logger {
    static let shared = JsonPersistenceManagerLogger()
    private init() {
        super.init(subsystem: "JsonPersistenceManager")
    }
}
