import XCTest
@testable import TokiToki

class GameEngineTests: XCTestCase {
    var gameEngine: GameEngine!
    var mockPlayer: GameStateEntity!
    var mockMonster: GameStateEntity!
    var mockBattleLogObserver: MockBattleLogObserver!
    var mockBattleEffectsDelegate: MockBattleEffectsDelegate!
    
    override func setUp() {
        super.setUp()
        
        // Create mock entities
        mockPlayer = createMockPlayer()
        mockMonster = createMockMonster()
        
        // Create mock observer and delegate
        mockBattleLogObserver = MockBattleLogObserver()
        mockBattleEffectsDelegate = MockBattleEffectsDelegate()
        
        // Initialize game engine
        gameEngine = GameEngine(playerTeam: [mockPlayer], opponentTeam: [mockMonster])
        gameEngine.addObserver(mockBattleLogObserver)
        gameEngine.addDelegate(mockBattleEffectsDelegate)
    }
    
    override func tearDown() {
        gameEngine = nil
        mockPlayer = nil
        mockMonster = nil
        mockBattleLogObserver = nil
        mockBattleEffectsDelegate = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createMockPlayer() -> GameStateEntity {
        let player = GameStateEntity("Test Player")
        
        // Add Stats Component
        let statsComponent = StatsComponent(
            entityId: player.id,
            maxHealth: 100,
            attack: 20,
            defense: 10,
            speed: 15,
            elementType: .fire
        )
        player.addComponent(statsComponent)
        
        // Add Skills Component
        let skillsComponent = SkillsComponent(entityId: player.id, skills: [
            createMockAttackSkill(),
            createMockHealSkill()
        ])
        player.addComponent(skillsComponent)
        
        // Add Status Effects Component
        let statusComponent = StatusEffectsComponent(entityId: player.id)
        player.addComponent(statusComponent)
        
        return player
    }
    
    private func createMockMonster() -> GameStateEntity {
        let monster = GameStateEntity("Test Monster")
        
        // Add Stats Component
        let statsComponent = StatsComponent(
            entityId: monster.id,
            maxHealth: 80,
            attack: 15,
            defense: 8,
            speed: 12,
            elementType: .water
        )
        monster.addComponent(statsComponent)
        
        // Add Skills Component
        let skillsComponent = SkillsComponent(entityId: monster.id, skills: [
            createMockAttackSkill()
        ])
        monster.addComponent(skillsComponent)
        
        // Add Status Effects Component
        let statusComponent = StatusEffectsComponent(entityId: monster.id)
        monster.addComponent(statusComponent)
        
        // Add AI Component
        let aiComponent = AIComponent(entityId: monster.id, rules: [
            HealthBelowPercentageRule(
                priority: 1,
                action: createMockAttackSkill(),
                percentage: 50
            )
        ], skills: [createMockAttackSkill()])
        monster.addComponent(aiComponent)
        
        return monster
    }
    
    private func createMockAttackSkill() -> Skill {
        return BaseSkill(
            name: "Test Attack",
            description: "A test attack skill",
            type: .attack,
            targetType: .singleEnemy,
            elementType: .fire,
            basePower: 100,
            cooldown: 0,
            statusEffectChance: 0,
            statusEffect: nil,
            effectCalculator: AttackCalculator(elementsSystem: ElementsSystem())
        )
    }
    
    private func createMockHealSkill() -> Skill {
        return BaseSkill(
            name: "Test Heal",
            description: "A test heal skill",
            type: .heal,
            targetType: .singleAlly,
            elementType: .neutral,
            basePower: 50,
            cooldown: 3,
            statusEffectChance: 0,
            statusEffect: nil,
            effectCalculator: HealCalculator()
        )
    }
    
    // MARK: - Tests
    
    func testStartBattle() {
        gameEngine.startBattle()
        XCTAssertEqual(mockBattleLogObserver.lastMessage, "Battle started!")
    }
    
    func testUseTokiSkill() {
        gameEngine.startBattle()
        gameEngine.useTokiSkill(0, [mockMonster])
        
        // Verify that the skill was used and damage was dealt
        XCTAssertTrue(mockBattleLogObserver.messages.contains { $0.contains("Test Player used Test Attack") })
        XCTAssertTrue(mockBattleLogObserver.messages.contains { $0.contains("damage") })
    }
    
    func testEntityDeath() {
        // Set monster's health to 1
        if let statsComponent = mockMonster.getComponent(ofType: StatsComponent.self) {
            statsComponent.currentHealth = 1
        }
        
        // Use attack skill
        gameEngine.startBattle()
        gameEngine.useTokiSkill(0, [mockMonster])
        
        // Verify monster was removed
        XCTAssertTrue(mockBattleEffectsDelegate.removedEntityIds.contains(mockMonster.id))
    }
    
    func testHealing() {
        // Damage the player
        if let statsComponent = mockPlayer.getComponent(ofType: StatsComponent.self) {
            statsComponent.currentHealth = 50
        }
        
        // Use heal skill
        gameEngine.startBattle()
        gameEngine.useTokiSkill(1, [mockPlayer])
        
        // Verify healing occurred
        XCTAssertTrue(mockBattleLogObserver.messages.contains { $0.contains("heal") })
    }
}

// MARK: - Mock Classes

class MockBattleLogObserver: BattleLogObserver {
    var messages: [String] = []
    var lastMessage: String?
    
    func update(log: [String]) {
        messages = log
        lastMessage = log.last
    }
}

class MockBattleEffectsDelegate: BattleEffectsDelegate {
    var removedEntityIds: [UUID] = []
    
    func showUseSkill(_ id: UUID, _ isLeft: Bool, completion: @escaping () -> Void) {
        completion()
    }
    
    func updateSkillIcons(_ skillIcons: [SkillUiInfo]?) {}
    
    func updateHealthBar(_ id: UUID, _ currentHealth: Int, _ maxHealth: Int) {}
    
    func removeDeadBody(_ id: UUID) {
        removedEntityIds.append(id)
    }
} 
