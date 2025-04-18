//
//  BattleEndSoundFXComponent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation

class BattleEndSoundFXComponent: SoundFXComponent<BattleEndedEvent> {
    private let configManager = SoundConfigurationManager.shared

    override func handleEvent(_ event: BattleEndedEvent) {
        if event.isWin {
            playSound(named: configManager.getVictorySound())
            logger.log("Playing victory sound")
        } else {
            playSound(named: configManager.getDefeatSound())
            logger.log("Playing defeat sound")
        }
    }
}
