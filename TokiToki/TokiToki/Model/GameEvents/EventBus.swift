//
//  EventBus.swift
//  TokiToki
//
//  Created by wesho on 22/3/25.
//

import Foundation

class EventBus {
    static let shared = EventBus()

    private var handlers: [String: [(GameEvent) -> Void]] = [:]

    private init() {}

    func register<E: GameEvent>(_ handler: @escaping (E) -> Void) {
        let eventTypeName = String(describing: E.self)

        if handlers[eventTypeName] == nil {
            handlers[eventTypeName] = []
        }

        let typeErasedHandler: (GameEvent) -> Void = { event in
            guard let typedEvent = event as? E else {
                return
            }
            handler(typedEvent)
        }

        handlers[eventTypeName]?.append(typeErasedHandler)
    }

    func post(_ event: GameEvent) {
        let eventTypeName = String(describing: type(of: event))
        handlers[eventTypeName]?.forEach { $0(event) }
        print(eventTypeName)
    }

    func clear() {
        handlers.removeAll()
    }
}
