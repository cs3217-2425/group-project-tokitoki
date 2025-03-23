//
//  VisualFXTests.swift
//  TokiTokiTests
//
//  Created by wesho on 23/3/25.
//

import XCTest
@testable import TokiToki

class VisualFXTests: XCTestCase {

    // MARK: - Test Case 1: TestEventBusRegistration

    func testEventBusRegistration() {
        let eventBus = EventBus.shared
        let expectation = expectation(description: "Event received")

        class MockVisualComponent {
            var eventReceived = false
            var expectation: XCTestExpectation

            init(expectation: XCTestExpectation) {
                self.expectation = expectation

                EventBus.shared.register { [weak self] (event: SkillUsedEvent) in
                    self?.eventReceived = true
                    self?.expectation.fulfill()
                }
            }
        }

        let mockComponent = MockVisualComponent(expectation: expectation)

        let skillEvent = SkillUsedEvent(
            entityId: UUID(),
            skillName: "Test Skill",
            elementType: .fire,
            targetIds: [UUID()]
        )
        eventBus.post(skillEvent)

        // Post a different type of event (shouldn't trigger our mock component)
        let damageEvent = DamageDealtEvent(
            sourceId: UUID(),
            targetId: UUID(),
            amount: 50,
            isCritical: false,
            elementType: .water
        )
        eventBus.post(damageEvent)

        waitForExpectations(timeout: 1.0)
        XCTAssertTrue(mockComponent.eventReceived, "Mock component should receive the registered event type")

        eventBus.clear()
    }

    // MARK: - Test Case 2: TestSkillVisualFXRegistry

    func testSkillVisualFXRegistry() {
        let registry = SkillVisualFXRegistry.shared

        // Create a mock skill visual effect
        class MockFireballVisualFX: SkillVisualFX {
            let sourceView: UIView
            let targetView: UIView

            init(sourceView: UIView, targetView: UIView) {
                self.sourceView = sourceView
                self.targetView = targetView
            }

            func play(completion: @escaping () -> Void) {
                // Mock implementation, call completion immediately
                completion()
            }
        }

        registry.register(skillName: "fireball") { sourceView, targetView in
            MockFireballVisualFX(sourceView: sourceView, targetView: targetView)
        }

        let sourceView = UIView()
        let targetView = UIView()

        // Retrieve the effect and verify
        let effect = registry.createVisualFX(for: "fireball", sourceView: sourceView, targetView: targetView)

        XCTAssertNotNil(effect, "Registry should return an effect for registered skill")
        XCTAssertTrue(effect is MockFireballVisualFX, "Registry should return the correct effect type")

        let unknownEffect = registry.createVisualFX(for: "unknown", sourceView: sourceView, targetView: targetView)
        XCTAssertNil(unknownEffect, "Registry should return nil for unregistered skills")
    }

    // MARK: - Test Case 3: TestStatusEffectVisualFXRegistry

    func testStatusEffectVisualFXRegistry() {
        let registry = StatusEffectVisualFXRegistry.shared

        // Create a mock status effect
        class MockBurnVisualFX: StatusEffectVisualFX {
            let targetView: UIView

            init(targetView: UIView) {
                self.targetView = targetView
            }

            func play(completion: @escaping () -> Void) {
                completion()
            }
        }

        // Register the effect
        registry.register(effectType: .burn) { targetView in
            MockBurnVisualFX(targetView: targetView)
        }

        let targetView = UIView()

        // Retrieve the effect and verify
        let effect = registry.createVisualFX(for: .burn, targetView: targetView)

        XCTAssertNotNil(effect, "Registry should return an effect for registered status type")
        XCTAssertTrue(effect is MockBurnVisualFX, "Registry should return the correct effect type")

        // Test unregistered status effect
        let unknownEffect = registry.createVisualFX(for: .frozen, targetView: targetView)
        XCTAssertNil(unknownEffect, "Registry should return nil for unregistered status effects")
    }

    // MARK: - Test Case 4: TestFireballVisualFXAnimation

    func testFireballVisualFXAnimation() {
        let sourceView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let targetView = UIView(frame: CGRect(x: 200, y: 200, width: 100, height: 100))

        // Add views to a test window to enable proper animation
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
        window.addSubview(sourceView)
        window.addSubview(targetView)
        window.makeKeyAndVisible()

        let fireballEffect = FireballVisualFX(sourceView: sourceView, targetView: targetView)

        let expectation = expectation(description: "Animation completed")

        fireballEffect.play {
            expectation.fulfill()
        }

        // Wait for the animation to complete with a reasonable timeout
        waitForExpectations(timeout: 2.0)

        // Use UI Testing to verify as this only verify that the play is called.
    }
}
