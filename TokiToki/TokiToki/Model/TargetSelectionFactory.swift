//
//  TargetSelectionFactory.swift
//  TokiToki
//
//  Created by proglab on 22/3/25.
//

class TargetSelectionFactory {
    private var targetTypesThatRequireSelection: Set<TargetType> = [.singleAlly, .singleEnemy]
    
    // switch case used here as the number of cases is small and fixed, targetType isn't expected to grow massively.
    func generateTargets(_ playerEntities: [GameStateEntity], _ opponentEntities: [GameStateEntity],
                         _ targetType: TargetType) -> [GameStateEntity] {
        switch targetType {
        case .all: return playerEntities + opponentEntities
        case .allAllies: return playerEntities
        case .allEnemies: return opponentEntities
        case .ownself: return playerEntities
        case .singleEnemy: return chooseRandomEntity(opponentEntities)
        case .singleAlly: return chooseRandomEntity(playerEntities)
        }
    }

    func chooseRandomEntity(_ entities: [GameStateEntity]) -> [GameStateEntity] {
        let entity = entities.randomElement()
        guard let entity = entity else {
            return []
        }
        return [entity]
    }

    func checkIfRequireTargetSelection(_ targetType: TargetType) -> Bool {
        targetTypesThatRequireSelection.contains(targetType)
    }
}
