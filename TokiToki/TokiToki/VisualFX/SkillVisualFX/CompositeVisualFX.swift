//
//  CompositeVisualFX.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

// Composite visual effect that combines multiple primitives
class CompositeVisualFX: SkillVisualFX {
    private let sourceView: UIView
    private let targetView: UIView

    private var primitives: [(VisualFXPrimitive, [String: Any])] = []

    init(sourceView: UIView, targetView: UIView) {
        self.sourceView = sourceView
        self.targetView = targetView
    }

    func getSourceView() -> UIView {
        sourceView
    }

    func getTargetView() -> UIView {
        targetView
    }

    func addPrimitive(_ primitive: VisualFXPrimitive, with parameters: [String: Any]) {
        var updatedParameters = parameters

        // Add a reference to the composite effect for primitives that need both source and target
        if primitive is ProjectilePrimitive {
            updatedParameters["compositeEffect"] = self
        }

        primitives.append((primitive, updatedParameters))
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
