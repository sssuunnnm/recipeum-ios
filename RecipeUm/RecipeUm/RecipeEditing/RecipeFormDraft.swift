//
//  RecipeFormDraft.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct RecipeFormDraft: Equatable {
    var title: String = ""
    var recipeDescription: String = ""
    var servingText: String = ""
    var cookingTimeMinutesText: String = ""
    var personalNotes: String = ""
    var categoryName: String = ""
    var ingredientText: String = ""
    var cookingStepText: String = ""
    var sourceType: RecipeSourceType = .other
    var sourceURLString: String = ""
    var sourceTitleOrMemo: String = ""

    var canSave: Bool {
        !title.trimmed.isEmpty
    }

    init() {}

    init(recipe: Recipe) {
        title = recipe.title
        recipeDescription = recipe.recipeDescription ?? ""
        servingText = recipe.servingText
        cookingTimeMinutesText = recipe.cookingTimeMinutes.map(String.init) ?? ""
        personalNotes = recipe.personalNotes
        categoryName = recipe.categoryName ?? ""
        ingredientText = recipe.sortedIngredientGroups
            .flatMap(\.sortedIngredients)
            .map(\.rawText)
            .joined(separator: "\n")
        cookingStepText = recipe.sortedCookingSteps
            .map(\.instruction)
            .joined(separator: "\n")
        sourceType = recipe.source?.type ?? .other
        sourceURLString = recipe.source?.urlString ?? ""
        sourceTitleOrMemo = recipe.source?.titleOrMemo ?? ""
    }

    func makeRecipe(
        at date: Date = Date(),
        parser: IngredientParser = IngredientParser()
    ) -> Recipe {
        let recipe = Recipe(
            title: title.trimmed,
            recipeDescription: recipeDescription.trimmedNilIfEmpty,
            servingText: servingText.trimmed,
            cookingTimeMinutes: cookingTimeMinutes,
            personalNotes: personalNotes.trimmed,
            categoryName: categoryName.trimmedNilIfEmpty,
            createdAt: date,
            updatedAt: date
        )
        recipe.ingredientGroups = makeIngredientGroups(parser: parser)
        recipe.cookingSteps = makeCookingSteps()
        recipe.source = makeSource()
        return recipe
    }

    private var cookingTimeMinutes: Int? {
        Int(cookingTimeMinutesText.trimmed)
    }

    private func makeIngredientGroups(parser: IngredientParser) -> [IngredientGroup] {
        let ingredients = parser
            .parseLines(ingredientText)
            .enumerated()
            .map { index, parsedIngredient in
                parsedIngredient.makeIngredient(sortOrder: index)
            }

        guard !ingredients.isEmpty else {
            return []
        }

        let group = IngredientGroup(title: "기본 재료", sortOrder: 0)
        group.ingredients = ingredients
        return [group]
    }

    private func makeCookingSteps() -> [CookingStep] {
        cookingStepText
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }
            .enumerated()
            .map { index, instruction in
                CookingStep(sortOrder: index, instruction: instruction)
            }
    }

    private func makeSource() -> RecipeSource? {
        let urlString = sourceURLString.trimmedNilIfEmpty
        let titleOrMemo = sourceTitleOrMemo.trimmed

        guard urlString != nil || !titleOrMemo.isEmpty else {
            return nil
        }

        return RecipeSource(
            type: sourceType,
            urlString: urlString,
            titleOrMemo: titleOrMemo
        )
    }
}

extension RecipeSourceType {
    var displayName: String {
        switch self {
        case .web:
            "웹"
        case .youtube:
            "YouTube"
        case .blog:
            "블로그"
        case .book:
            "책"
        case .personal:
            "직접 작성"
        case .other:
            "기타"
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedNilIfEmpty: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
