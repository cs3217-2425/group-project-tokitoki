//
//  TokiFactory.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/4/25.
//

import Foundation

protocol TokiFactoryProtocol {
    func getAllTemplates() -> [TokiData]
    func getTemplate(named name: String) -> TokiData?
    func createToki(from data: TokiData) -> Toki
    func createRandomToki() -> Toki?
}

/// Loads Toki templates from JSON and builds `Toki` instances.
class TokiFactory: TokiFactoryProtocol {
    // MARK: - Properties

    private var templates: [String: TokiData] = [:]
    private let logger = Logger(subsystem: "TokiFactory")
    private let skillsFactory: SkillsFactoryProtocol

    // MARK: - Initialization

    init(skillsFactory: SkillsFactoryProtocol) {
        self.skillsFactory = skillsFactory
        loadTemplates()
    }

    // MARK: - Public Methods

    /// All available Toki templates.
    func getAllTemplates() -> [TokiData] {
        Array(templates.values)
    }

    /// Template by name, or nil if none.
    func getTemplate(named name: String) -> TokiData? {
        templates[name]
    }

    /// Build a concrete `Toki` from its template.
    func createToki(from data: TokiData) -> Toki {
        let baseStats = TokiBaseStats(
            hp: data.baseHealth,
            attack: data.baseAttack,
            defense: data.baseDefense,
            speed: data.baseSpeed,
            heal: data.baseHeal,
            exp: data.baseExp
        )

        let skills = createSkillsFromNames(data.skills)
        let elementType = ElementType.fromString(data.elementType) ?? .neutral

        return Toki(
            name: data.name,
            rarity: convertIntToItemRarity(data.rarity),
            baseStats: baseStats,
            skills: skills,
            equipments: [],
            elementType: [elementType],
            level: 1
        )
    }

    /// Create a random Toki (useful for testing/demo purposes)
    func createRandomToki() -> Toki? {
        guard let template = templates.values.randomElement() else {
            return nil
        }
        return createToki(from: template)
    }

    // MARK: - Private Methods

    private func loadTemplates() {
        do {
            let tokisData: TokisData = try ResourceLoader.loadJSON(fromFile: "Tokis")
            for tmpl in tokisData.tokis {
                templates[tmpl.name] = tmpl
            }
            logger.log("Loaded \(templates.count) Toki templates")
        } catch {
            logger.logError("Failed to load Toki templates: \(error)")
        }
    }

    private func createSkillsFromNames(_ names: [String]) -> [Skill] {
        names.compactMap { name in
            guard let skillData = skillsFactory.getTemplate(named: name) else {
                return nil
            }
            return skillsFactory.createSkill(from: skillData)
        }
    }

    private func convertIntToItemRarity(_ value: Int) -> ItemRarity {
        ItemRarity(intValue: value) ?? .common
    }
}
