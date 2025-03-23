//
//  EquipmentFactory.swift
//  TokiToki
//
//  Created by Wh Kang on 22/3/25.
//

import Foundation

/// EquipmentFactory creates Equipment instances with a provided name, description, element type, and buff.
class EquipmentFactory {
    
    /// Creates an Equipment instance with the specified properties.
    func createEquipment(name: String, description: String, elementType: ElementType, buff: Buff) -> Equipment {
        // Wrap the provided Buff in a CombinedBuffComponent.
        let buffComponent = CombinedBuffComponent(buff: buff)
        // Create and return the Equipment instance with the buff component.
        return Equipment(name: name, description: description, elementType: elementType, components: [buffComponent])
    }
}
