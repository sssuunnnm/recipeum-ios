//
//  IngredientReviewState.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct IngredientReviewState: Equatable {
    var inputText: String
    private(set) var items: [IngredientReviewItem]

    var hasReviewItems: Bool {
        !items.isEmpty
    }

    var reviewRequiredCount: Int {
        items.filter(\.needsReview).count
    }

    init(inputText: String = "", items: [IngredientReviewItem] = []) {
        self.inputText = inputText
        self.items = items
    }

    mutating func parseInput(using parser: IngredientParser = IngredientParser()) {
        items = parser
            .parseLines(inputText)
            .map { parsedIngredient in
                IngredientReviewItem(parsedIngredient: parsedIngredient)
            }
    }

    mutating func updateItem(
        id: IngredientReviewItem.ID,
        name: String,
        amountText: String?,
        unit: String?
    ) {
        guard let index = items.firstIndex(where: { $0.id == id }) else {
            return
        }

        items[index].applyManualCorrection(
            name: name,
            amountText: amountText,
            unit: unit
        )
    }

    func makeIngredients() -> [RecipeIngredient] {
        items.enumerated().map { index, item in
            item.makeIngredient(sortOrder: index)
        }
    }
}
