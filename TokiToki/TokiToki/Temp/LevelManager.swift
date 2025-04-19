//
//  LevelManager.swift
//  TokiToki
//
//  Created by proglab on 19/4/25.
//

class LevelManager {
    var level: Level
    var bosses: [Toki] = [dragonMonsterToki, necroMonsterToki, electricFoxMonsterToki]
    var minions: [Toki] = [rhinoMonsterToki, golemMonsterToki, totemMonsterToki]
    
    init(level: Level) {
        self.level = level
        let modifier = level.statModifier
        
        self.bosses = [dragonMonsterToki, necroMonsterToki, electricFoxMonsterToki].map { toki in
            cloneToki(toki, modifier)
        }

        self.minions = [rhinoMonsterToki, golemMonsterToki, totemMonsterToki].map { toki in
            cloneToki(toki, modifier)
        }
    }
    
    private func cloneToki(_ toki: Toki, _ modifier: TokiBaseStats) -> Toki {
        let newStats = toki.baseStats.addStats(modifier)
        let newToki = toki.clone()
        newToki.baseStats = newStats
        return newToki
    }
    
    func getEnemies() -> [Toki] {
        guard let boss = bosses.randomElement() else {
            return []
        }
        
        return [boss]
        //+ Array(minions.shuffled().prefix(2))
    }
    
    func getExp() -> Int {
        return level.expReward
    }
}

enum Level: Int, CaseIterable {
    case easy = 0
    case normal = 10
    case hard = 20
    case hell = 30
    
    private static let levelToExp: [Level: Int] = [
        .easy: 500,
        .normal: 1500,
        .hard: 3000,
        .hell: 6000
    ]
    
    var statModifier: TokiBaseStats {
        let multiplier = self.rawValue
        return TokiBaseStats(
            hp: 10 * multiplier,
            attack: 3 * multiplier,
            defense: 1 * multiplier,
            speed: 0 * multiplier,
            heal: 2 * multiplier,
            exp: 0
        )
    }
    
    var expReward: Int {
        let base = Level.levelToExp[self] ?? 0
        return Int.random(in: Int(Double(base) * 0.9)...Int(Double(base) * 1.1))
    }
}
