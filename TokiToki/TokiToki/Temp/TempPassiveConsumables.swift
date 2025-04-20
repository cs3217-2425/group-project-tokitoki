//
//  TempPassiveConsumables.swift
//  TokiToki
//
//  Created by proglab on 15/4/25.
//


let revivalCalculator = ReviveCalculator(revivePower: 1.0)
let revivalRingEffectStrategy = RevivalRingEffectStrategy(effectCalculators: [revivalCalculator])
let revivalRing = EquipmentFactory()
    .createConsumableEquipment(name: "Revival Ring",
                               description: "A ring that revives a Toki to full health when it dies",
                               rarity: 1, effectStrategy: revivalRingEffectStrategy,
                               usageContext: .battleOnlyPassive)

