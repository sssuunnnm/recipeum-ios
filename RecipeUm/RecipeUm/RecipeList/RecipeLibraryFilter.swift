//
//  RecipeLibraryFilter.swift
//  RecipeUm
//
//  Created by Codex on 8/25/26.
//

import Foundation

struct RecipeLibraryFilter: Equatable {
    var searchText: String = ""
    var categoryName: String?

    func filteredRecipes(from recipes: [Recipe]) -> [Recipe] {
        recipes.filter(matches)
    }

    func matches(_ recipe: Recipe) -> Bool {
        matchesCategory(recipe) && matchesSearchText(recipe)
    }

    private func matchesCategory(_ recipe: Recipe) -> Bool {
        guard let categoryName, !categoryName.normalizedForLibrarySearch.isEmpty else {
            return true
        }

        return recipe.categoryName?.normalizedForLibrarySearch == categoryName.normalizedForLibrarySearch
    }

    private func matchesSearchText(_ recipe: Recipe) -> Bool {
        let query = searchText.normalizedForLibrarySearch

        guard !query.isEmpty else {
            return true
        }

        if recipe.title.normalizedForLibrarySearch.contains(query) {
            return true
        }

        return recipe.sortedIngredientGroups
            .flatMap(\.sortedIngredients)
            .contains { ingredient in
                ingredient.name.normalizedForLibrarySearch.contains(query)
                || ingredient.rawText.normalizedForLibrarySearch.contains(query)
            }
    }
}

extension Sequence where Element == Recipe {
    func availableCategoryNames() -> [String] {
        let categoryNames = compactMap { recipe in
            recipe.categoryName?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        .filter { !$0.isEmpty }

        return Array(Set(categoryNames)).sorted()
    }
}

private extension String {
    var normalizedForLibrarySearch: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
