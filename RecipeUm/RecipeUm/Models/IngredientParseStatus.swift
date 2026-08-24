//
//  IngredientParseStatus.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

enum IngredientParseStatus: String, Codable, CaseIterable {
    case parsed
    case needsReview
}

