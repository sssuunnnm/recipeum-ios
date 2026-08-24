//
//  IngredientAmountValueParser.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

enum IngredientAmountValueParser {
    nonisolated static func numericValue(from amountText: String) -> Double? {
        let trimmedAmount = amountText.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedAmount == "반" {
            return 0.5
        }

        if trimmedAmount.contains("/") {
            let parts = trimmedAmount.split(separator: "/")
            guard
                parts.count == 2,
                let numerator = Double(parts[0]),
                let denominator = Double(parts[1]),
                denominator != 0
            else {
                return nil
            }

            return numerator / denominator
        }

        return Double(trimmedAmount)
    }
}
