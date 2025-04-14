//
//  GlobalStatusEffectsManager.swift
//  TokiToki
//
//  Created by proglab on 14/4/25.
//

class GlobalStatusEffectsManager: GlobalStatusEffectsManaging {
    private var globalStatusEffects: [StatusEffect] = []
    private let statusEffectsSystem: StatusEffectsSystem
    
    init(_ statusEffectsSystem: StatusEffectsSystem) {
        self.statusEffectsSystem = statusEffectsSystem
    }
    
    func addGlobalStatusEffect(_ statusEffect: StatusEffect) {}
    func removeGlobalStatusEffect(_ statusEffect: StatusEffect) {}
}
