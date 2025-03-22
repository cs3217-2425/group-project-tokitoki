import XCTest
@testable import TokiToki

class EffectCalculatorTests: XCTestCase {
    var mockSource: GameStateEntity!
    var mockTarget: GameStateEntity!
    var mockSkill: Skill!
    var elementsSystem = ElementsSystem()

    override func setUp() {
        super.setUp()

        // Create mock entities
        mockSource = createMockEntity(name: "Source", health: 100, attack: 20, defense: 10, elementType: .fire)
        mockTarget = createMockEntity(name: "Target", health: 100, attack: 15, defense: 8, elementType: .water)

        // Create mock skill
        mockSkill = createMockSkill()
    }

    override func tearDown() {
        mockSource = nil
        mockTarget = nil
        mockSkill = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func createMockEntity(name: String, health: Int, attack: Int, defense: Int, elementType: ElementType) -> GameStateEntity {
        let entity = GameStateEntity(name)

        let statsComponent = StatsComponent(
            entityId: entity.id,
            maxHealth: health,
            attack: attack,
            defense: defense,
            speed: 10,
            elementType: elementType
        )
        entity.addComponent(statsComponent)

        return entity
    }

    private func createMockSkill() -> Skill {
        BaseSkill(
            name: "Test Skill",
            description: "A test skill",
            type: .attack,
            targetType: .singleEnemy,
            elementType: .fire,
            basePower: 100,
            cooldown: 0,
            statusEffectChance: 0.0,
            statusEffect: nil,
            statusEffectDuration: 0,
            effectCalculator: AttackCalculator(elementsSystem: elementsSystem)
        )
    }

    // MARK: - Attack Calculator Tests

    func testAttackCalculatorBaseDamage() {
        // Create a neutral element target to avoid element effectiveness
        let neutralTarget = createMockEntity(name: "Neutral Target", health: 100, attack: 15, defense: 8, elementType: .neutral)

        let calculator = AttackCalculator(elementsSystem: elementsSystem)
        let result = calculator.calculate(skill: mockSkill, source: mockSource, target: neutralTarget)

        // Base damage formula: (attack * basePower / 100) - (defense / 4)
        // (20 * 100 / 100) - (8 / 4) = 20 - 2 = 18
        XCTAssertEqual(result.value, 18)
        XCTAssertEqual(result.type, .damage)
    }

    func testAttackCalculatorElementEffectiveness() {
        // Fire vs Water should be not very effective (0.5x)
        let calculator = AttackCalculator(elementsSystem: elementsSystem)
        let result = calculator.calculate(skill: mockSkill, source: mockSource, target: mockTarget)

        // Base damage * element multiplier
        // 18 * 0.5 = 9
        XCTAssertEqual(result.value, 9)
        XCTAssertTrue(result.description.contains("not very effective"))
    }

    func testAttackCalculatorCriticalHit() {
        // Note: This test might occasionally fail due to random critical hit chance
        // In a real test environment, you might want to mock the random number generator
        let calculator = AttackCalculator(elementsSystem: elementsSystem)
        let result = calculator.calculate(skill: mockSkill, source: mockSource, target: mockTarget)

        if result.description.contains("critical hit") {
            // If critical hit occurred, damage should be 1.5x
            XCTAssertEqual(result.value, 13) // 9 * 1.5
        } else {
            // If no critical hit, damage should be normal
            XCTAssertEqual(result.value, 9)
        }
    }

    // MARK: - Heal Calculator Tests

    func testHealCalculator() {
        let calculator = HealCalculator()
        let healSkill = BaseSkill(
            name: "Test Heal",
            description: "A test heal skill",
            type: .heal,
            targetType: .singleAlly,
            elementType: .neutral,
            basePower: 50,
            cooldown: 0,
            statusEffectChance: 0.0,
            statusEffect: nil,
            statusEffectDuration: 0,
            effectCalculator: calculator
        )

        // Damage the target first
        if let statsComponent = mockTarget.getComponent(ofType: StatsComponent.self) {
            statsComponent.currentHealth = 50
        }

        let result = calculator.calculate(skill: healSkill, source: mockSource, target: mockTarget)

        // Heal formula: basePower + (attack / 2)
        // 50 + (20 / 2) = 50 + 10 = 60
        XCTAssertEqual(result.value, 60)
        XCTAssertEqual(result.type, .heal)
    }

    // MARK: - Defense Calculator Tests

    func testDefenseCalculator() {
        let calculator = DefenseCalculator()
        let defenseSkill = BaseSkill(
            name: "Test Defense",
            description: "A test defense skill",
            type: .defend,
            targetType: .singleAlly,
            elementType: .neutral,
            basePower: 20,
            cooldown: 0,
            statusEffectChance: 0.0,
            statusEffect: nil,
            statusEffectDuration: 0,
            effectCalculator: calculator
        )

        let result = calculator.calculate(skill: defenseSkill, source: mockSource, target: mockTarget)

        XCTAssertEqual(result.value, 20)
        XCTAssertEqual(result.type, .defense)
    }
}
