//
//  RecipeCategoryCatalog.swift
//  RecipeUm
//
//  Created by Codex on 8/26/26.
//

import Foundation

struct RecipeCategorySummary: Equatable, Identifiable {
    var id: String {
        name.normalizedForCategoryCatalog
    }

    let name: String
    let recipeCount: Int
}

enum RecipeCategoryCatalog {
    static let defaultCategoryNames = [
        "한식",
        "양식",
        "일식",
        "중식",
        "디저트",
        "기타",
    ]

    static func editorOptions(including currentCategoryName: String) -> [String] {
        let currentCategoryName = currentCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        let baseOptions = [""] + defaultCategoryNames

        guard !currentCategoryName.isEmpty,
              !baseOptions.contains(where: { $0.normalizedForCategoryCatalog == currentCategoryName.normalizedForCategoryCatalog })
        else {
            return baseOptions
        }

        return baseOptions + [currentCategoryName]
    }

    static func summaries(for recipes: [Recipe]) -> [RecipeCategorySummary] {
        var summariesByKey: [String: RecipeCategorySummary] = [:]
        var categoryKeys: [String] = []

        for recipe in recipes {
            guard let categoryName = recipe.categoryName?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !categoryName.isEmpty
            else {
                continue
            }

            let key = categoryName.normalizedForCategoryCatalog
            if let summary = summariesByKey[key] {
                summariesByKey[key] = RecipeCategorySummary(
                    name: summary.name,
                    recipeCount: summary.recipeCount + 1
                )
            } else {
                categoryKeys.append(key)
                summariesByKey[key] = RecipeCategorySummary(name: categoryName, recipeCount: 1)
            }
        }

        return categoryKeys
            .compactMap { summariesByKey[$0] }
            .sorted { $0.name < $1.name }
    }
}

private extension String {
    var normalizedForCategoryCatalog: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
