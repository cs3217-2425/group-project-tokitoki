//
//  AVSoundPlayer.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import Foundation
import AVFoundation

class AVSoundPlayer: SoundPlayerProtocol {
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    private let soundCache = NSCache<NSString, AVAudioPlayer>()

    func playSound(named soundName: String, volume: Float = 1.0) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found: \(soundName)")
            return
        }

        // Check if sound is already cached
        if let cachedPlayer = soundCache.object(forKey: soundName as NSString) {
            cachedPlayer.volume = volume
            cachedPlayer.currentTime = 0
            cachedPlayer.play()
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()
            soundCache.setObject(player, forKey: soundName as NSString)
            player.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}
