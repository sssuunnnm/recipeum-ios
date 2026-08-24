//
//  ParsedIngredient.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct ParsedIngredient: Equatable {
    var rawText: String
    var name: String
    var amountText: String?
    var amountValue: Double?
    var amountUpperValue: Double?
    var unit: String?
    var parseStatus: IngredientParseStatus

    func makeIngredient(sortOrder: Int) -> RecipeIngredient {
        RecipeIngredient(
            rawText: rawText,
            name: name,
            amountText: amountText,
            amountValue: amountValue,
            amountUpperValue: amountUpperValue,
            unit: unit,
            parseStatus: parseStatus,
            sortOrder: sortOrder
        )
    }
}

