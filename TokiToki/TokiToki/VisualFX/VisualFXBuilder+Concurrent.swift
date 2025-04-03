//
//  VisualFXBuilder+Concurrent.swift
//  TokiToki
//
//  Created by wesho on 3/4/25.
//

import UIKit

extension VisualFXBuilder {
    // Commit the current group and start a new one
    func beginConcurrentGroup() -> VisualFXBuilder {
        if let compositeEffect = compositeEffect as? CompositeVisualFX {
            compositeEffect.commitGroup()
        }
        return self
    }
}
