//
//  CompositeVisualFX.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Composite visual effect that combines multiple primitives
class CompositeVisualFX: SkillVisualFX {
    private var primitives: [(VisualFXPrimitive, [String: Any])] = []
    private let sourceView: UIView
    private let targetView: UIView

    init(sourceView: UIView, targetView: UIView) {
        self.sourceView = sourceView
        self.targetView = targetView
    }

    func addPrimitive(_ primitive: VisualFXPrimitive, with parameters: [String: Any]) {
        primitives.append((primitive, parameters))
    }

    func play(completion: @escaping () -> Void) {
        playNextPrimitive(index: 0, completion: completion)
    }

    private func playNextPrimitive(index: Int, completion: @escaping () -> Void) {
        guard index < primitives.count else {
            completion()
            return
        }

        let (primitive, parameters) = primitives[index]
        let isTargetEffect = parameters["isTargetEffect"] as? Bool ?? false
        let view = isTargetEffect ? targetView : sourceView

        primitive.apply(to: view, with: parameters) { [self] in
            self.playNextPrimitive(index: index + 1, completion: completion)
        }
    }
}
