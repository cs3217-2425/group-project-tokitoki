//
//  DamageSoundFXComponent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

class DamageSoundFXComponent: SoundFXComponent<DamageDealtEvent> {    
    init(soundPlayer: SoundPlayerProtocol, elementSoundMap: [ElementType: String] = [:]) {
        super.init(soundPlayer: soundPlayer)
    }
    
    override func handleEvent(_ event: DamageDealtEvent) {
        if event.isCritical {
            playSound(named: "critical_hit")
            logger.log("Playing critical hit sound")
            return
        } else {
            playSound(named: "default_damage")
        }
        
        logger.log("Playing damage sound")
    }
}
