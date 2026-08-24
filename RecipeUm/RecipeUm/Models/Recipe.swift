//
//  Recipe.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    var title: String
    var recipeDescription: String?
    var representativeImageData: Data?
    var servingText: String
    var cookingTimeMinutes: Int?
    var personalNotes: String
    var isFavorite: Bool
    var categoryName: String?
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \IngredientGroup.recipe)
    var ingredientGroups: [IngredientGroup]

    @Relationship(deleteRule: .cascade, inverse: \CookingStep.recipe)
    var cookingSteps: [CookingStep]

    @Relationship(deleteRule: .cascade, inverse: \RecipeSource.recipe)
    var source: RecipeSource?

    init(
        title: String,
        recipeDescription: String? = nil,
        representativeImageData: Data? = nil,
        servingText: String = "",
        cookingTimeMinutes: Int? = nil,
        personalNotes: String = "",
        isFavorite: Bool = false,
        categoryName: String? = nil,
        ingredientGroups: [IngredientGroup] = [],
        cookingSteps: [CookingStep] = [],
        source: RecipeSource? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.title = title
        self.recipeDescription = recipeDescription
        self.representativeImageData = representativeImageData
        self.servingText = servingText
        self.cookingTimeMinutes = cookingTimeMinutes
        self.personalNotes = personalNotes
        self.isFavorite = isFavorite
        self.categoryName = categoryName
        self.ingredientGroups = ingredientGroups
        self.cookingSteps = cookingSteps
        self.source = source
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    func markUpdated(at date: Date = Date()) {
        updatedAt = date
    }
}

