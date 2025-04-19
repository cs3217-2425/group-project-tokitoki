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
                "Flame Dance": "fire_skill",
                "Excalibur": "slash",
                "Ice Shot": "ice_skill",
                "Arrow Rain": "soft_aoe",
                "Lightning Storm": "soft_aoe",
                "Earthquake": "earthquake",
                "Acid Spray": "soft_aoe"
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
