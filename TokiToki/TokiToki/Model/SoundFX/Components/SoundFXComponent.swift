//
//  SoundFXComponent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation
import AVFoundation

class SoundFXComponent<E: GameEvent> {
    private let soundPlayer: SoundPlayerProtocol
    internal let logger = Logger(subsystem: "SoundFXComponent")

    init(soundPlayer: SoundPlayerProtocol) {
        self.soundPlayer = soundPlayer
        registerHandlers()
    }

    func registerHandlers() {
        EventBus.shared.register { [weak self] (event: E) in
            self?.handleEvent(event)
        }
    }

    func handleEvent(_ event: E) {
        // Base implementation does nothing
        // Subclasses will override to implement specific sound effects
    }

    func playSound(named soundName: String, volume: Float = 1.0) {
        soundPlayer.playSound(named: soundName, volume: volume)
    }
}

protocol SoundPlayerProtocol {
    func playSound(named: String, volume: Float)
}
