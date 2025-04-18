//
//  EffectComponent.swift
//  TokiToki
//
//  Created by wesho on 22/3/25.
//

// EffectComponent.swift
import UIKit

class VisualFXComponent<E: BattleEvent> {
    private let viewProvider: ((UUID) -> UIView?)
    internal let logger = Logger(subsystem: "VisualFXComponent")

    init(viewProvider: @escaping (UUID) -> UIView?) {
        self.viewProvider = viewProvider
        registerHandlers()
    }

    func registerHandlers() {
        EventBus.shared.register { [weak self] (event: E) in
            self?.handleEvent(event)
        }
    }

    func handleEvent(_ event: E) {
        // Base implementation does nothing
        // Subclasses will override to implement specific effects
    }

    func getView(for entityId: UUID) -> UIView? {
        viewProvider(entityId)
    }
}
