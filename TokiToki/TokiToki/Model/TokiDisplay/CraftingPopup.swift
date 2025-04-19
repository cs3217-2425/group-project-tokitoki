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
        [originalItem, selectedItem].compactMap { $0 }.forEach { item in
            if let idx = toki.equipments.firstIndex(where: { $0.id == item.id }) {
                toki.equipments.remove(at: idx)
            }
            equipmentComponent.inventory.removeAll { $0.id == item.id }
        }
        if originalItemIndex >= toki.equipments.count {
            toki.equipments.append(craftedItem)
        } else {
            toki.equipments.insert(craftedItem, at: originalItemIndex)
        }
        equipmentComponent.inventory.append(craftedItem)
    }
}
