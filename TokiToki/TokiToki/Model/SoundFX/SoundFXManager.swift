//
//  SoundFXManager.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

class SoundFXManager {
    // Singleton because sound effect manager is being used globally
    static let shared = SoundFXManager()

    private var soundComponents: [Any] = []
    private let soundPlayer: SoundPlayerProtocol

    private let configManager = SoundConfigurationManager.shared

    // MARK: - Initialization

    private init(soundPlayer: SoundPlayerProtocol? = nil) {
        self.soundPlayer = soundPlayer ?? AVSoundPlayer()
        setupSoundComponents()
    }

    private func setupSoundComponents() {
        // Battle sound components
        setupBattleSoundComponents()

        // Gacha sound components
        setupGachaSoundComponents()
    }

    // MARK: - Component Setup

    private func setupBattleSoundComponents() {
//        var statusSoundMap: [StatusEffectType: String] = [:]
//        for (statusString, soundName) in configManager.configuration.statusEffectSounds {
//            if let statusType = StatusEffectType(rawValue: statusString) {
//                statusSoundMap[statusType] = soundName
//            }
//        }

        soundComponents.append(contentsOf: [
            SkillSoundFXComponent(soundPlayer: soundPlayer,
                                 skillSoundMap: configManager.configuration.skillSounds),
            DamageSoundFXComponent(soundPlayer: soundPlayer),
            BattleEndSoundFXComponent(soundPlayer: soundPlayer)
        ])
    }

    private func setupGachaSoundComponents() {
        soundComponents.append(contentsOf: [
            GachaPullSoundFXComponent(soundPlayer: soundPlayer)
        ])
    }

    // MARK: - Cleanup
    func cleanup() {
        soundComponents.removeAll()
    }
}
