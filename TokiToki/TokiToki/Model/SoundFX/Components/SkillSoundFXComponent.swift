//
//  SkillSoundFXComponent.swift
//  TokiToki
//
//  Created by wesho on 19/4/25.
//

import Foundation

class SkillSoundFXComponent: SoundFXComponent<SkillUsedEvent> {
    private let skillSoundMap: [String: String]
    private let configManager = SoundConfigurationManager.shared
    
    init(soundPlayer: SoundPlayerProtocol, skillSoundMap: [String: String]) {
        self.skillSoundMap = skillSoundMap
        super.init(soundPlayer: soundPlayer)
    }
    
    override func handleEvent(_ event: SkillUsedEvent) {
        let soundName = getSkillSoundName(for: event.skillName)
        playSound(named: soundName)
    }
    
    private func getSkillSoundName(for skillName: String) -> String {
        return configManager.getSkillSound(for: skillName)
    }
}
