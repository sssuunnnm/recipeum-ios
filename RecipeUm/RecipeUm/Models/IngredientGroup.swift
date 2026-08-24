//
//  IngredientGroup.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class IngredientGroup {
    var title: String
    var sortOrder: Int
    var recipe: Recipe?

    @Relationship(deleteRule: .cascade, inverse: \RecipeIngredient.group)
    var ingredients: [RecipeIngredient]

    var sortedIngredients: [RecipeIngredient] {
        ingredients.sorted { lhs, rhs in
            lhs.sortOrder < rhs.sortOrder
        }
    }

    init(
        title: String,
        sortOrder: Int,
        ingredients: [RecipeIngredient] = []
    ) {
        self.title = title
        self.sortOrder = sortOrder
        self.ingredients = ingredients
    }
}
