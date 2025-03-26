//
//  TokiDisplayCustomizationTests.swift
//  TokiToki
//
//  Created by Wh Kang on 23/3/25.
//

import XCTest
@testable import TokiToki  // Replace with your actual module name

// Dummy concrete implementation for the Skill protocol to use in tests.
struct TestSkill: Skill {
    // Provide required properties with dummy values.
    let id = UUID()

    // Using assumed enums from your module:
    let type: SkillType        // e.g., SkillType.basic
    let targetType: TargetType // e.g., TargetType.single
    let elementType: ElementType // e.g., ElementType.fire

    let basePower: Int
    let cooldown: Int
    var currentCooldown: Int
    let statusEffectChance: Double
    let statusEffectDuration: Int
    let statusEffect: StatusEffectType? // For example, nil if no effect

    let name: String
    let description: String
    let power: Int

    // Dummy implementations of protocol methods.
    func canUse() -> Bool {
        // Dummy logic: always return true for testing.
        true
    }

    func use(from source: any Entity, on targets: [any Entity]) -> [EffectResult] {
        // Dummy implementation returning an empty array.
        []
    }

    func startCooldown() {
        // Dummy implementation.
    }

    func reduceCooldown() {
        // Dummy implementation.
    }

    func perform() {
        // Dummy implementation for testing purposes.
    }
}

class TokiDisplayCustomizationTests: XCTestCase {

    // MARK: - Singleton Tests

    func testTokiDisplaySingleton() {
        let instance1 = TokiDisplay.shared
        let instance2 = TokiDisplay.shared
        XCTAssertTrue(instance1 === instance2, "TokiDisplay should be a singleton.")
    }

    // MARK: - Default Toki Initialization Tests

    func testDefaultTokiInitialization() {
        let display = TokiDisplay.shared
        let toki = display.toki

        // Verify default values (adjust expected values as needed)
        XCTAssertEqual(toki.name, "Default Toki", "Default Toki name should be 'Default Toki'")
        XCTAssertEqual(toki.level, 1, "Default Toki level should be 1")

        // Verify default stats (assuming TokiBaseStats is a struct with these properties)
        XCTAssertEqual(toki.baseStats.hp, 100, "Default HP should be 100")
        XCTAssertEqual(toki.baseStats.attack, 50, "Default attack should be 50")
        XCTAssertEqual(toki.baseStats.defense, 50, "Default defense should be 50")
        XCTAssertEqual(toki.baseStats.speed, 50, "Default speed should be 50")
    }

    // MARK: - Customization Update Tests

    func testAddingEquipmentUpdatesToki() {
        let display = TokiDisplay.shared
        let toki = display.toki

        // Record initial equipment count
        let initialEquipmentCount = toki.equipment.count

        // Create dummy equipment for testing
        let newEquipment = Equipment(
            name: "Test Staff",
            description: "A magical staff for testing purposes",
            elementType: .fire,  // Adjust if ElementType is defined differently
            components: []       // Assuming an empty array is acceptable
        )

        // Simulate adding equipment
        toki.equipment.append(newEquipment)
        XCTAssertEqual(toki.equipment.count, initialEquipmentCount + 1, "Equipment count should increase by one after adding new equipment.")
    }

    // MARK: - Edge Case Tests

    func testRemovingNonExistentEquipment() {
        let display = TokiDisplay.shared
        let toki = display.toki
        let initialCount = toki.equipment.count

        // Try to remove equipment with a name that doesn't exist
        let nonExistentName = "Non Existent Equipment"
        if let index = toki.equipment.firstIndex(where: { $0.name == nonExistentName }) {
            toki.equipment.remove(at: index)
        }

        // The equipment count should remain unchanged
        XCTAssertEqual(toki.equipment.count, initialCount, "Removing non-existent equipment should not change the equipment count.")
    }

    func testAddingDuplicateEquipment() {
        let display = TokiDisplay.shared
        let toki = display.toki
        let initialCount = toki.equipment.count

        let duplicateEquipment = Equipment(
            name: "Duplicate Staff",
            description: "Duplicate equipment for testing",
            elementType: .fire,
            components: []
        )
        // Add duplicate equipment twice
        toki.equipment.append(duplicateEquipment)
        toki.equipment.append(duplicateEquipment)

        let duplicateCount = toki.equipment.filter { $0.name == "Duplicate Staff" }.count
        XCTAssertEqual(duplicateCount, 2, "Duplicate equipment should be added twice if allowed.")
        XCTAssertEqual(toki.equipment.count, initialCount + 2, "Equipment count should increase by 2 after adding duplicate equipment.")
    }

    func testAddingEquipmentWithEmptyName() {
        let display = TokiDisplay.shared
        let toki = display.toki
        let initialCount = toki.equipment.count

        let emptyNameEquipment = Equipment(
            name: "",
            description: "Equipment with an empty name",
            elementType: .fire,
            components: []
        )

        toki.equipment.append(emptyNameEquipment)
        XCTAssertEqual(toki.equipment.count, initialCount + 1, "Equipment count should increase even when equipment name is empty.")
        XCTAssertEqual(toki.equipment.last?.name, "", "The name of the last equipment should be an empty string.")
    }

    func testEdgeCaseStatUpdateNegativeValue() {
        let display = TokiDisplay.shared
        let toki = display.toki

        // Create a mutable copy of the current baseStats
        var currentStats = toki.baseStats
        let originalAttack = currentStats.attack

        // Update attack value to a negative number
        currentStats = TokiBaseStats(
            hp: currentStats.hp,
            attack: -5,
            defense: currentStats.defense,
            speed: currentStats.speed,
            heal: currentStats.heal,
            exp: currentStats.exp
        )
        toki.baseStats = currentStats

        // Verify that the negative value is set
        XCTAssertEqual(toki.baseStats.attack, -5, "Toki attack should update to -5 if negative values are allowed.")
    }

    func testAddingDuplicateSkill() {
        let display = TokiDisplay.shared
        let toki = display.toki
        let initialSkillCount = toki.skills.count

        let duplicateSkill = TestSkill(
            type: .heal,                      // Assumes SkillType.basic exists
             targetType: .single,               // Assumes TargetType.single exists
             elementType: .fire,                // Assumes ElementType.fire exists
             basePower: 100,
             cooldown: 5,
             currentCooldown: 0,
             statusEffectChance: 0.0,
             statusEffectDuration: 0,
             statusEffect: nil,
             name: "Duplicate Skill",
             description: "A duplicate skill for testing",
             power: 10
         )
        toki.skills.append(duplicateSkill)
        toki.skills.append(duplicateSkill)

        let duplicateCount = toki.skills.filter { $0.name == "Duplicate Skill" }.count
        XCTAssertEqual(duplicateCount, 2, "Skill count for duplicate skills should be 2 if allowed.")
        XCTAssertEqual(toki.skills.count, initialSkillCount + 2, "Skill count should increase by 2 after adding duplicate skills.")
    }

    // MARK: - Performance Tests

    func testPerformanceOfAddingMultipleEquipments() {
        let display = TokiDisplay.shared
        let toki = display.toki

        // Measure performance for adding 100 equipment items
        measure {
            for i in 1...100 {
                let equipment = Equipment(
                    name: "Equipment \(i)",
                    description: "Test equipment \(i)",
                    elementType: .fire,
                    components: []
                )
                toki.equipment.append(equipment)
            }
        }
    }

    func testPerformanceOfAddingMultipleSkills() {
        let display = TokiDisplay.shared
        let toki = display.toki

        // Measure performance for adding 100 skills
        measure {
            for i in 1...100 {
                let skill = TestSkill(
                    type: .attack,
                    targetType: .single,
                    elementType: .fire,
                    basePower: 100,
                    cooldown: 5,
                    currentCooldown: 0,
                    statusEffectChance: 0.0,
                    statusEffectDuration: 0,
                    statusEffect: nil,
                    name: "Skill \(i)",
                    description: "Test skill \(i)",
                    power: i
                )
                toki.skills.append(skill)
            }
        }
    }
}
