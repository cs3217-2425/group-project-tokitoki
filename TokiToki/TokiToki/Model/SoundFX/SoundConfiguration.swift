//
//  SoundConfiguration.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

// Struct to hold sound configuration data
struct SoundConfiguration: Codable {
    // Battle related sound effects
    var skillSounds: [String: String]
    var elementSounds: [String: String]
    var statusEffectSounds: [String: String]

    var defeatSound: String
    var victorySound: String
    var healingSound: String
    var criticalHitSound: String

    var defaultSkillSound: String
    var defaultDamageSound: String
    var defaultStatusSound: String

    static var defaultConfiguration: SoundConfiguration {
        SoundConfiguration(
            skillSounds: [
                "Fireball": "fire_skill",
                "Ice Shard": "ice_skill",
                "Lightning Bolt": "lightning_skill"
            ],
            elementSounds: [
                "fire": "fire_impact",
                "water": "water_impact",
                "earth": "earth_impact",
                "air": "air_impact"
            ],
            statusEffectSounds: [
                "poison": "poison_effect",
                "burn": "burn_effect",
                "freeze": "freeze_effect"
            ],
            defeatSound: "defeat",
            victorySound: "victory",
            healingSound: "healing",
            criticalHitSound: "critical_hit",
            defaultSkillSound: "default_skill",
            defaultDamageSound: "default_damage",
            defaultStatusSound: "status_effect"
        )
    }
}
