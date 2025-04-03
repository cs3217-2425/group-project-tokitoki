//
//  ProjectilePrimitive.swift
//  TokiToki
//
//  Created by wesho on 31/3/25.
//

import UIKit

class ProjectilePrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        guard let projectileParams = parameters["parameters"] as? ProjectileParameters else {
            completion()
            return
        }

        // Get both source and target views from the CompositeVisualFX
        guard let compositeEffect = parameters["compositeEffect"] as? CompositeVisualFX else {
            print("Error: ProjectilePrimitive requires a reference to the CompositeVisualFX")
            completion()
            return
        }

        let sourceView = compositeEffect.getSourceView()
        let targetView = compositeEffect.getTargetView()

        let projectile = Projectile(
            sourceView: sourceView,
            targetView: targetView,
            parameters: projectileParams
        )

        // Launch the projectile
        projectile.launch {
            completion()
        }
    }
}
