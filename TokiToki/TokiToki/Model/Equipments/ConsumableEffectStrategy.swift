//
//  ConsumableEffectStrategy.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

protocol ConsumableEffectStrategy {
    func applyEffect(to toki: Toki, completion: (() -> Void)?)
}

struct PotionEffectStrategy: ConsumableEffectStrategy {
    let buffValue: Int
    let duration: TimeInterval
    
    func applyEffect(to toki: Toki, completion: (() -> Void)? = nil) {
        print("Applying Potion: +\(buffValue) attack for \(duration) seconds")
        // For a full implementation, schedule a temporary buff removal.
        toki.addTemporaryBuff(value: buffValue, duration: duration, stat: "attack")
        completion?()
    }
}

struct UpgradeCandyEffectStrategy: ConsumableEffectStrategy {
    let bonusExp: Int
    
    func applyEffect(to toki: Toki, completion: (() -> Void)? = nil) {
        print("Applying Upgrade Candy: +\(bonusExp) EXP permanently")
        toki.gainExperience(bonusExp)
        completion?()
    }
}