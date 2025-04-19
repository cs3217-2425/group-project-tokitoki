//
//  GachaPullSoundFXComponent.swift
//  TokiToki
//
//  Created by wesho on 19/4/25.
//

import Foundation

class GachaPullSoundFXComponent: SoundFXComponent<GachaPullEvent> {
    private let configManager = SoundConfigurationManager.shared

    override func handleEvent(_ event: GachaPullEvent) {
        playSound(named: "gacha_pull")
    }
}
