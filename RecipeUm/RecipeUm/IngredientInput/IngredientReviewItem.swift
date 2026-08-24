//
//  IngredientReviewItem.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct IngredientReviewItem: Identifiable, Equatable {
    var id: UUID
    var rawText: String
    var name: String
    var amountText: String?
    var amountValue: Double?
    var amountUpperValue: Double?
    var unit: String?
    var parseStatus: IngredientParseStatus

    var needsReview: Bool {
        parseStatus == .needsReview
    }

    init(id: UUID = UUID(), parsedIngredient: ParsedIngredient) {
        self.id = id
        self.rawText = parsedIngredient.rawText
        self.name = parsedIngredient.name
        self.amountText = parsedIngredient.amountText
        self.amountValue = parsedIngredient.amountValue
        self.amountUpperValue = parsedIngredient.amountUpperValue
        self.unit = parsedIngredient.unit
        self.parseStatus = parsedIngredient.parseStatus
    }

    mutating func applyManualCorrection(name: String, amountText: String?, unit: String?) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.amountText = amountText?.trimmedNilIfEmpty
        self.amountValue = self.amountText.flatMap(IngredientAmountValueParser.numericValue)
        self.amountUpperValue = nil
        self.unit = unit?.trimmedNilIfEmpty
        self.parseStatus = self.name.isEmpty ? .needsReview : .parsed
    }

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

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
