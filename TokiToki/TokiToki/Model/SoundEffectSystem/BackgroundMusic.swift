//
//  BackgroundMusic.swift
//  TokiToki
//
//  Created by Wh Kang on 18/4/25.
//


import Foundation
import AVFoundation

// MARK: - Public API

/// Enumerate each background track.  `rawValue` must match the filename (no extension).
public enum BackgroundMusic: String, CaseIterable {
    case mainMenu    = "main_menu"
    case battleTheme = "battle_theme"
    // Append new tracks here and add the corresponding file to your bundle
}

/// Protocol for injection/mocking in tests
public protocol BackgroundMusicPlaying: AnyObject {
    var isMuted: Bool { get set }
    var volume: Float { get set }
    func play(_ music: BackgroundMusic, loop: Bool)
    func pause()
    func stop()
    func skipToNextTrack()
}

// MARK: - Concrete Implementation

public final class BackgroundMusicManager: NSObject, BackgroundMusicPlaying {

    // Singleton-like but resolved via ServiceLocator
    public static let shared = BackgroundMusicManager()
    private var player: AVAudioPlayer?
    private var currentTrack: BackgroundMusic?
    private let session = AVAudioSession.sharedInstance()

    /// Persisted user setting
    public var isMuted: Bool {
        get { UserDefaults.standard.bool(forKey: "bgm_muted") }
        set {
            UserDefaults.standard.set(newValue, forKey: "bgm_muted")
            player?.volume = newValue ? 0 : volume
        }
    }

    /// Persisted user volume [0...1]
    public var volume: Float {
        get { UserDefaults.standard.float(forKey: "bgm_volume") }
        set {
            UserDefaults.standard.set(newValue, forKey: "bgm_volume")
            player?.volume = isMuted ? 0 : newValue
        }
    }

    private override init() { super.init() }

    /// Activate audio session.  Called automatically on first access.
    public func prepare() {
        do {
            try session.setCategory(.playback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("[BGM] AVAudioSession error: \(error)")
        }
    }

    public func play(_ music: BackgroundMusic, loop: Bool = true) {
        guard !isMuted else { return }

        // If same track, just resume
        if currentTrack == music, let p = player {
            p.play()
            return
        }

        // Load new track
        guard let url = Bundle.main.url(forResource: music.rawValue, withExtension: "mp3") else {
            assertionFailure("Missing background file: \(music.rawValue).mp3")
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = loop ? -1 : 0
            p.volume = volume
            p.prepareToPlay()
            p.play()
            player = p
            currentTrack = music
        } catch {
            print("[BGM] Failed to load \(music.rawValue): \(error)")
        }
    }

    public func pause() {
        player?.pause()
    }

    public func stop() {
        player?.stop()
        player = nil
        currentTrack = nil
    }

    public func skipToNextTrack() {
        guard let curr = currentTrack,
              let idx = BackgroundMusic.allCases.firstIndex(of: curr) else { return }
        let next = BackgroundMusic.allCases[(idx + 1) % BackgroundMusic.allCases.count]
        play(next)
    }
}

// MARK: - Ergonomic Facade

public enum Music {
    /// Play or resume a track
    public static func play(_ music: BackgroundMusic, loop: Bool = true) {
        BackgroundMusicManager.shared.play(music, loop: loop)
    }
    public static func pause() {
        BackgroundMusicManager.shared.pause()
    }
    public static func stop() {
        BackgroundMusicManager.shared.stop()
    }
    public static func mute(_ flag: Bool) {
        BackgroundMusicManager.shared.isMuted = flag
    }
    public static func setVolume(_ value: Float) {
        BackgroundMusicManager.shared.volume = value
    }
}
