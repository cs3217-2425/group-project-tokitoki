//
//  CraftingError.swift
//  TokiToki
//
//  Created by Wh Kang on 19/4/25.
//

import Foundation

enum CraftingError: Error {
    case noSelection
    case invalidRecipe
}

class CraftingModel {
    private let equipmentComponent: EquipmentComponent
    private let toki: Toki
    let originalItem: Equipment
    let originalItemIndex: Int
    private(set) var availableItems: [Equipment] = []
    var selectedItem: Equipment?

    init(tokiDisplay: TokiDisplay, originalItem: Equipment, originalItemIndex: Int) {
        self.equipmentComponent = tokiDisplay.equipmentFacade.equipmentComponent
        self.toki = tokiDisplay.toki
        self.originalItem = originalItem
        self.originalItemIndex = originalItemIndex
        computeAvailableItems(from: tokiDisplay)
    }

    private func computeAvailableItems(from tokiDisplay: TokiDisplay) {
        let allEquippedIDs = Set(
            tokiDisplay.allTokis.flatMap { $0.equipments.map(\.id) }
        )
        availableItems = equipmentComponent.inventory.filter { inv in
            inv.id != originalItem.id && !allEquippedIDs.contains(inv.id)
        }
    }

    func craft(withFacade facade: AdvancedEquipmentFacade) throws -> Equipment {
        guard let second = selectedItem else {
            throw CraftingError.noSelection
        }
        let itemsToCraft = [originalItem, second]
        guard let crafted = facade.craftItems(items: itemsToCraft) else {
            throw CraftingError.invalidRecipe
        }
        updateState(with: crafted)
        return crafted
    }

    private func updateState(with craftedItem: Equipment) {

        // Collect the two source items
        let ingredients = [originalItem, selectedItem].compactMap { $0 }

        // 1. Remove from every place they might live
        for item in ingredients {

            // ‑‑ inventory
            equipmentComponent.inventory.removeAll { $0.id == item.id }

            // ‑‑ equipped slots
            equipmentComponent.equipped = equipmentComponent.equipped
                .filter { $0.value.id != item.id }

            // ‑‑ the Toki’s local array (buff calculations, etc.)
            toki.equipments.removeAll { $0.id == item.id }
        }

        // 2. Add the crafted item back to the Toki (same visual position)
        if originalItemIndex >= toki.equipments.count {
            toki.equipments.append(craftedItem)
        } else {
            toki.equipments.insert(craftedItem, at: originalItemIndex)
        }

        // 3. Ensure it’s present exactly once in inventory
        if !equipmentComponent.inventory.contains(where: { $0.id == craftedItem.id }) {
            equipmentComponent.inventory.append(craftedItem)
        }
    }
}
