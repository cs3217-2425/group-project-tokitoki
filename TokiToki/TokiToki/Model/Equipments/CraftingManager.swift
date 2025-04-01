//
//  CraftingManager.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

class CraftingManager {
    private var recipes: [CraftingRecipe] = []
    
    init(recipes: [CraftingRecipe]) {
        self.recipes = recipes
    }
    
    func register(recipe: CraftingRecipe) {
        recipes.append(recipe)
    }
    
    func craft(with equipments: [Equipment]) -> Equipment? {
        for recipe in recipes {
            if recipe.matches(equipments: equipments) {
                return recipe.resultEquipmentFactory(equipments)
            }
        }
        return nil
    }
}