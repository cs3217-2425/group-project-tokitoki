//
//  SoundEffect.swift
//  TokiToki
//
//  Created by Wh Kang on 18/4/25.
//


import Foundation
import AVFoundation

// MARK: ‑ Public API

/// List every SFX cue you intend to ship.  The `rawValue` must match the **filename**
/// (without extension) that you place in the main bundle.
public enum SoundEffect: String, CaseIterable {
    case buttonTap     = "button_tap"
    case gachaPull     = "gacha_pull"
    case battleStart   = "battle_start"
    case victory       = "victory"
    case defeat        = "defeat"
    case burn          = "burn"
    case fireball      = "fireball"
    case lightning     = "lightning"
    case paralysis     = "paralysis"
    case slash         = "slash"
    case flamedance    = "flamedance"
    case iceArrow      = "ice_arrow"
    case death         = "death"
    case equip         = "equip"
    case unequip       = "unequip"
    case craft         = "craft"
    case potionUse     = "potion_use"
    case revive        = "revive"
    case levelUp       = "level_up"
    case expUp         = "exp_up"
    case damageTaken   = "damage_taken"
    case popUp         = "pop_up"
    
    // Add new cues → drop a *.wav (or .mp3) and append a case ‑ done.
}

/// Abstraction so you can inject / mock the sound layer in unit‑tests.
public protocol SoundEffectPlaying: AnyObject {
    func play(_ effect: SoundEffect, volume: Float)
    func stop(_ effect: SoundEffect)
    func stopAll()
    var isMuted: Bool { get set }
}

// MARK: ‑ Concrete implementation

/// AVAudioPlayer‑based implementation.  Not a hard singleton ‑ access via `ServiceLocator`.
public final class SoundEffectManager: NSObject, SoundEffectPlaying {

    // Shared instance for convenience; still resolved via ServiceLocator.
    public static let shared = SoundEffectManager()

    private let session = AVAudioSession.sharedInstance()
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private(set) var isPrepared = false
    private let logger = Logger(subsystem: "SoundEffectManager")

    public var isMuted: Bool {
        get { UserDefaults.standard.bool(forKey: "sfx_muted") }
        set { UserDefaults.standard.setValue(newValue, forKey: "sfx_muted") }
    }

    private override init() { super.init() }

    /// Call once (e.g. SceneDelegate) **before** first use, or let `prepare()` lazily auto‑run.
    public func prepare() {
        guard !isPrepared else { return }

        do {
            try session.setCategory(.ambient, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            logger.logError("AVAudioSession error: \(error)")
        }

        SoundEffect.allCases.forEach { effect in
            guard let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "mp3") else {
                assertionFailure("Missing audio file \(effect.rawValue).mp3 – forgot to add it to the target?")
                return
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players[effect] = player
            } catch {
                logger.logError("Failed to load \(effect): \(error)")
            }
        }
        isPrepared = true
    }

    // MARK: ‑ SoundEffectPlaying
    public func play(_ effect: SoundEffect, volume: Float = 1.0) {
        guard !isMuted else { return }
        if !isPrepared { prepare() }
        guard let player = players[effect] else { return }
        player.volume = volume
        player.currentTime = 0 // rewind for repeated taps
        player.play()
    }

    public func stop(_ effect: SoundEffect) {
        players[effect]?.stop()
    }

    public func stopAll() {
        players.values.forEach { $0.stop() }
    }
}

// MARK: ‑ Ergonomic facade

/// Global helper so call‑sites stay ultra‑concise (`Sound.play(.gachaPull)`).
public enum Sound {
    public static func play(_ effect: SoundEffect, volume: Float = 1.0) {
        SoundEffectManager.shared.play(effect, volume: volume)
    }
    public static func mute(_ flag: Bool) {
        SoundEffectManager.shared.isMuted = flag
    }
}
