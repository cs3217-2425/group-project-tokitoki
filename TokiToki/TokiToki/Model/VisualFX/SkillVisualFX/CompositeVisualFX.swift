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

    // Groups of primitives - each group is executed concurrently, but groups are executed sequentially
    private var primitiveGroups: [[(VisualFXPrimitive, [String: Any])]] = []

    // Current group being built
    private var currentGroup: [(VisualFXPrimitive, [String: Any])] = []

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

    // Add a primitive to the current group (will be executed concurrently with others in this group)
    func addPrimitive(_ primitive: VisualFXPrimitive, with parameters: [String: Any]) {
        var updatedParameters = parameters

        // Add a reference to the composite effect for primitives that need both source and target
        if primitive is ProjectilePrimitive {
            updatedParameters["compositeEffect"] = self
        }

        currentGroup.append((primitive, updatedParameters))
    }

    // Commit the current group of primitives and start a new one
    func commitGroup() {
        if !currentGroup.isEmpty {
            primitiveGroups.append(currentGroup)
            currentGroup = []
        }
    }

    func play(completion: @escaping () -> Void) {
        // Add any remaining primitives in the current group
        commitGroup()

        // Play all groups in sequence
        playNextGroup(index: 0, completion: completion)
    }

    private func playNextGroup(index: Int, completion: @escaping () -> Void) {
        guard index < primitiveGroups.count else {
            completion()
            return
        }

        let currentGroup = primitiveGroups[index]

        // If group is empty, move to next group
        if currentGroup.isEmpty {
            playNextGroup(index: index + 1, completion: completion)
            return
        }

        // For concurrent execution, we need to track when all primitives in the group are complete
        var completedCount = 0
        let totalCount = currentGroup.count

        // Closure to check if all primitives in the group are complete
        let groupCompletionCheck = {
            completedCount += 1
            if completedCount == totalCount {
                // All primitives in this group are finished, move to next group
                self.playNextGroup(index: index + 1, completion: completion)
            }
        }

        // Play all primitives in the current group concurrently
        for (primitive, parameters) in currentGroup {
            let isTargetEffect = parameters["isTargetEffect"] as? Bool ?? false
            let view = isTargetEffect ? targetView : sourceView

            primitive.apply(to: view, with: parameters) {
                groupCompletionCheck()
            }
        }
    }
}
