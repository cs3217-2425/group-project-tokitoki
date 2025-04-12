//
//  Untitled.swift
//  TokiToki
//
//  Created by proglab on 15/3/25.
//

protocol EffectCalculator: Codable {
    var type: EffectCalculatorType { get }
    func calculate(moveName: String, source: GameStateEntity, target: GameStateEntity) -> EffectResult?
    func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws
}

extension EffectCalculator {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EffectCalculatorCodingKeys.self)
        try container.encode(type, forKey: .type)
        try encodeAdditionalProperties(to: &container)
    }

    func encodeAdditionalProperties(to container: inout KeyedEncodingContainer<EffectCalculatorCodingKeys>) throws {
        // Default empty implementation
    }
}

enum EffectCalculatorType: String, Codable {
    case attack
    case heal
    case statsModifiers
    case statusEffect
}

enum EffectCalculatorCodingKeys: String, CodingKey {
    case type
    case elementType
    case basePower
    case healPower
    case statsModifiers
    case statusEffectChance
    case statusEffect
    case statusEffectDuration
    case statusEffectStrength
}

