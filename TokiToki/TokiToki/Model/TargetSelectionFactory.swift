//
//  TargetSelectionFactory.swift
//  TokiToki
//
//  Created by proglab on 22/3/25.
//

class TargetSelectionFactory {
    private var playerEntities: [GameStateEntity] = []
    private var opponentEntities: [GameStateEntity] = []
    private var targetTypeToTargets: [TargetType: [GameStateEntity]] = [:]
    private var targetTypesThatRequireSelection: Set<TargetType> = [.singleAlly, .singleEnemy]

    func generateTargets(_ playerEntities: [GameStateEntity], _ opponentEntities: [GameStateEntity],
                         _ targetType: TargetType) -> [GameStateEntity] {
        self.playerEntities = playerEntities
        self.opponentEntities = opponentEntities
        self.targetTypeToTargets = [
            .all: playerEntities + opponentEntities,
            .allAllies: playerEntities,
            .allEnemies: opponentEntities,
            .ownself: playerEntities,
            .singleEnemy: chooseRandomEntity(opponentEntities),
            .singleAlly: chooseRandomEntity(playerEntities)
        ]
        return targetTypeToTargets[targetType] ?? []
    }

    func chooseRandomEntity(_ entities: [GameStateEntity]) -> [GameStateEntity] {
        let entity = entities.randomElement()
        guard let entity = entity else {
            return []
        }
        return [entity]
    }

    func makeTargetSelection(_ targetType: TargetType) -> [GameStateEntity] {
        guard let targets = targetTypeToTargets[targetType] else {
            return []
        }
        return targets
    }

    func checkIfRequireTargetSelection(_ targetType: TargetType) -> Bool {
        targetTypesThatRequireSelection.contains(targetType)
    }
}
