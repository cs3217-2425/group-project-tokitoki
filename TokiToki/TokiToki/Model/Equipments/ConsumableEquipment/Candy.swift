//
//  Candy.swift
//  TokiToki
//
//  Created by proglab on 5/4/25.
//

//import Foundation
//
//class Candy: ConsumableEquipment {
//    var id = UUID()
//    var name: String
//    var description: String
//    var equipmentType: EquipmentType = .consumable
//    var rarity: Int
//    let bonusExp: Int
//    var usageContext: ConsumableUsageContext = .outOfBattleOnly
//
//    init(name: String, description: String, rarity: Int, bonusExp: Int) {
//        self.name = name
//        self.description = description
//        self.rarity = rarity
//        self.bonusExp = bonusExp
//    }
//
//    func applyEffect(to toki: Toki?, _ entity: GameStateEntity?, completion: (() -> Void)? = nil)
//    -> [EffectResult]? {
//        print("Applying Upgrade Candy: +\(bonusExp) EXP permanently")
//        toki?.gainExperience(bonusExp)
//        completion?()
//        return nil
//    }
//}
