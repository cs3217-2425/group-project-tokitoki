//
//  SoundConfigurationManager.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

class SoundConfigurationManager {
    static let shared = SoundConfigurationManager()

    var configuration: SoundConfiguration

    private init() {
        // Initialize with default configuration
        self.configuration = SoundConfiguration.defaultConfiguration

        // Try to load from file and replace
        if let loadedConfig = loadConfigurationFromFile() {
            self.configuration = loadedConfig
        }
    }

    private func loadConfigurationFromFile() -> SoundConfiguration? {
        guard let url = Bundle.main.url(forResource: "SoundConfiguration", withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode(SoundConfiguration.self, from: data)
        } catch {
            print("Error loading sound configuration: \(error)")
            return nil
        }
    }

    // MARK: - Configuration Access Methods

    func getSkillSound(for skillName: String) -> String {
        configuration.skillSounds[skillName] ?? configuration.defaultSkillSound
    }

//    func getStatusEffectSound(for effectType: StatusEffectType) -> String {
//        let effectName = String(describing: effectType).lowercased()
//        return configuration.statusEffectSounds[effectName] ?? configuration.defaultStatusSound
//    }

    func getHealingSound() -> String {
        configuration.healingSound
    }

    func getCriticalHitSound() -> String {
        configuration.criticalHitSound
    }

    func getVictorySound() -> String {
        configuration.victorySound
    }

    func getDefeatSound() -> String {
        configuration.defeatSound
    }
}
