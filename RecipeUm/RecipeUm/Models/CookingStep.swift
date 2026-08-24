//
//  CookingStep.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class CookingStep {
    var sortOrder: Int
    var instruction: String
    var imageData: Data?
    var recipe: Recipe?

    init(
        sortOrder: Int,
        instruction: String,
        imageData: Data? = nil
    ) {
        self.sortOrder = sortOrder
        self.instruction = instruction
        self.imageData = imageData
    }
}

