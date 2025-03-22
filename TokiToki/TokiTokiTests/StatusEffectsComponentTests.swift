import XCTest
@testable import TokiToki

class StatusEffectsComponentTests: XCTestCase {
    var statusEffectsComponent: StatusEffectsComponent!
    var mockEntity: GameStateEntity!
    
    override func setUp() {
        super.setUp()
        
        mockEntity = GameStateEntity("Test Entity")
        statusEffectsComponent = StatusEffectsComponent(entityId: mockEntity.id)
        mockEntity.addComponent(statusEffectsComponent)
    }
    
    override func tearDown() {
        statusEffectsComponent = nil
        mockEntity = nil
        super.tearDown()
    }
    
    // MARK: - Status Effect Application Tests
    
    func testApplyStatusEffect() {
        let effect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        statusEffectsComponent.addEffect(effect)
        
        XCTAssertEqual(statusEffectsComponent.activeEffects.count, 1)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first?.type, .burn)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first?.remainingDuration, 3)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first?.strength, 1.0)
    }
    
    func testApplyMultipleStatusEffects() {
        let burnEffect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        let poisonEffect = StatusEffect(type: .poison, remainingDuration: 2, strength: 1.0, sourceId: mockEntity.id)
        
        statusEffectsComponent.addEffect(burnEffect)
        statusEffectsComponent.addEffect(poisonEffect)
        
        XCTAssertEqual(statusEffectsComponent.activeEffects.count, 2)
        XCTAssertTrue(statusEffectsComponent.activeEffects.contains { $0.type == .burn })
        XCTAssertTrue(statusEffectsComponent.activeEffects.contains { $0.type == .poison })
    }
    // MARK: - Status Effect Processing Tests
    
    func testProcessStatusEffects() {
        let burnEffect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        let poisonEffect = StatusEffect(type: .poison, remainingDuration: 2, strength: 1.0, sourceId: mockEntity.id)
        
        statusEffectsComponent.addEffect(burnEffect)
        statusEffectsComponent.addEffect(poisonEffect)
        
        // Process effects once
        statusEffectsComponent.updateEffects()
        
        XCTAssertEqual(statusEffectsComponent.activeEffects.count, 2)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first { $0.type == .burn }?.remainingDuration, 2)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first { $0.type == .poison }?.remainingDuration, 1)
    }
    
    func testStatusEffectExpiration() {
        let effect = StatusEffect(type: .burn, remainingDuration: 1, strength: 1.0, sourceId: mockEntity.id)
        statusEffectsComponent.addEffect(effect)
        
        // Process effects once
        statusEffectsComponent.updateEffects()
        
        XCTAssertTrue(statusEffectsComponent.activeEffects.isEmpty)
    }
    
    // MARK: - Status Effect Removal Tests
    
    func testRemoveStatusEffect() {
        let effect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        statusEffectsComponent.addEffect(effect)
        
        statusEffectsComponent.removeEffect(id: effect.id)
        
        XCTAssertTrue(statusEffectsComponent.activeEffects.isEmpty)
    }
    
    func testRemoveNonExistentStatusEffect() {
        let effect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        statusEffectsComponent.addEffect(effect)
        
        statusEffectsComponent.removeEffect(id: UUID())
        
        XCTAssertEqual(statusEffectsComponent.activeEffects.count, 1)
        XCTAssertEqual(statusEffectsComponent.activeEffects.first?.type, .burn)
    }
    
    // MARK: - Status Effect Query Tests
    
    func testHasStatusEffect() {
        let effect = StatusEffect(type: .burn, remainingDuration: 3, strength: 1.0, sourceId: mockEntity.id)
        statusEffectsComponent.addEffect(effect)
        
        XCTAssertTrue(statusEffectsComponent.hasEffect(ofType: .burn))
        XCTAssertFalse(statusEffectsComponent.hasEffect(ofType: .poison))
    }
} 
