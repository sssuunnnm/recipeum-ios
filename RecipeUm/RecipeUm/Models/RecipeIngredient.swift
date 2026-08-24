//
//  RecipeIngredient.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class RecipeIngredient {
    var rawText: String
    var name: String
    var amountText: String?
    var amountValue: Double?
    var amountUpperValue: Double?
    var unit: String?
    var parseStatusRawValue: String
    var sortOrder: Int
    var group: IngredientGroup?

    var parseStatus: IngredientParseStatus {
        get {
            IngredientParseStatus(rawValue: parseStatusRawValue) ?? .needsReview
        }
        set {
            parseStatusRawValue = newValue.rawValue
        }
    }

    init(
        rawText: String,
        name: String,
        amountText: String? = nil,
        amountValue: Double? = nil,
        amountUpperValue: Double? = nil,
        unit: String? = nil,
        parseStatus: IngredientParseStatus = .needsReview,
        sortOrder: Int
    ) {
        self.rawText = rawText
        self.name = name
        self.amountText = amountText
        self.amountValue = amountValue
        self.amountUpperValue = amountUpperValue
        self.unit = unit
        self.parseStatusRawValue = parseStatus.rawValue
        self.sortOrder = sortOrder
    }
}

