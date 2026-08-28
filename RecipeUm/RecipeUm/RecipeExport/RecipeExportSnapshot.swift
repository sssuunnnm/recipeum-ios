//
//  RecipeExportSnapshot.swift
//  RecipeUm
//
//  Created by Codex on 8/27/26.
//

import Foundation

struct RecipeExportSnapshot: Equatable {
    var title: String
    var recipeDescription: String?
    var servingText: String
    var cookingTimeText: String?
    var categoryName: String?
    var ingredientGroups: [IngredientGroupSnapshot]
    var cookingSteps: [CookingStepSnapshot]
    var personalNotes: String?
    var source: SourceSnapshot?

    init(
        title: String,
        recipeDescription: String?,
        servingText: String,
        cookingTimeText: String?,
        categoryName: String?,
        ingredientGroups: [IngredientGroupSnapshot],
        cookingSteps: [CookingStepSnapshot],
        personalNotes: String?,
        source: SourceSnapshot?
    ) {
        self.title = title
        self.recipeDescription = recipeDescription
        self.servingText = servingText
        self.cookingTimeText = cookingTimeText
        self.categoryName = categoryName
        self.ingredientGroups = ingredientGroups
        self.cookingSteps = cookingSteps
        self.personalNotes = personalNotes
        self.source = source
    }

    @MainActor
    init(recipe: Recipe) {
        title = recipe.title
        recipeDescription = recipe.recipeDescription?.trimmedNilIfEmpty
        servingText = recipe.servingText.trimmingCharacters(in: .whitespacesAndNewlines)
        cookingTimeText = recipe.cookingTimeMinutes.map { "\($0)분" }
        categoryName = recipe.categoryName?.trimmedNilIfEmpty
        ingredientGroups = recipe.sortedIngredientGroups
            .map(IngredientGroupSnapshot.init(group:))
            .filter { !$0.ingredients.isEmpty }
        cookingSteps = recipe.sortedCookingSteps.enumerated().map { index, step in
            CookingStepSnapshot(step: step, displayNumber: index + 1)
        }
        personalNotes = recipe.personalNotes.trimmedNilIfEmpty
        source = recipe.source.map(SourceSnapshot.init(source:))
    }

    func applyingExportOptions(
        includesPersonalNotes: Bool,
        includesSourceMetadata: Bool
    ) -> RecipeExportSnapshot {
        var snapshot = self

        if !includesPersonalNotes {
            snapshot.personalNotes = nil
        }

        if !includesSourceMetadata {
            snapshot.source = nil
        }

        return snapshot
    }
}

extension RecipeExportSnapshot {
    struct IngredientGroupSnapshot: Equatable, Identifiable {
        var id: Int { sortOrder }
        var sortOrder: Int
        var title: String
        var ingredients: [IngredientSnapshot]

        init(sortOrder: Int, title: String, ingredients: [IngredientSnapshot]) {
            self.sortOrder = sortOrder
            self.title = title
            self.ingredients = ingredients
        }

        @MainActor
        init(group: IngredientGroup) {
            sortOrder = group.sortOrder
            title = group.title
            ingredients = group.sortedIngredients.map(IngredientSnapshot.init(ingredient:))
        }
    }

    struct IngredientSnapshot: Equatable, Identifiable {
        var id: Int { sortOrder }
        var sortOrder: Int
        var rawText: String
        var name: String
        var amountAndUnitText: String

        init(sortOrder: Int, rawText: String, name: String, amountAndUnitText: String) {
            self.sortOrder = sortOrder
            self.rawText = rawText
            self.name = name
            self.amountAndUnitText = amountAndUnitText
        }

        @MainActor
        init(ingredient: RecipeIngredient) {
            sortOrder = ingredient.sortOrder
            rawText = ingredient.rawText
            name = ingredient.name
            amountAndUnitText = [ingredient.amountText, ingredient.unit]
                .compactMap { value in
                    let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines)
                    return trimmedValue?.isEmpty == false ? trimmedValue : nil
                }
                .joined()
        }
    }

    struct CookingStepSnapshot: Equatable, Identifiable {
        var id: Int { number }
        var number: Int
        var instruction: String

        init(number: Int, instruction: String) {
            self.number = number
            self.instruction = instruction
        }

        @MainActor
        init(step: CookingStep, displayNumber: Int) {
            number = displayNumber
            instruction = step.instruction
        }
    }

    struct SourceSnapshot: Equatable {
        var typeName: String
        var urlString: String?
        var titleOrMemo: String?

        init(typeName: String, urlString: String?, titleOrMemo: String?) {
            self.typeName = typeName
            self.urlString = urlString
            self.titleOrMemo = titleOrMemo
        }

        @MainActor
        init(source: RecipeSource) {
            typeName = source.type.displayName
            urlString = source.urlString?.trimmedNilIfEmpty
            titleOrMemo = source.titleOrMemo.trimmedNilIfEmpty
        }
    }
}

extension RecipeExportSnapshot.SourceSnapshot {
    var hasDisplayContent: Bool {
        urlString != nil || titleOrMemo != nil
    }
}

#if DEBUG
extension RecipeExportSnapshot {
    static var preview: RecipeExportSnapshot {
        RecipeExportSnapshot(
            title: "김치볶음밥",
            recipeDescription: "남은 밥으로 빠르게 만드는 한 그릇",
            servingText: "1인분",
            cookingTimeText: "15분",
            categoryName: "밥",
            ingredientGroups: [
                IngredientGroupSnapshot(
                    sortOrder: 0,
                    title: "기본 재료",
                    ingredients: [
                        IngredientSnapshot(sortOrder: 0, rawText: "밥 1공기", name: "밥", amountAndUnitText: "1공기"),
                        IngredientSnapshot(sortOrder: 1, rawText: "김치 100g", name: "김치", amountAndUnitText: "100g"),
                    ]
                ),
            ],
            cookingSteps: [
                CookingStepSnapshot(number: 1, instruction: "김치를 충분히 볶는다."),
                CookingStepSnapshot(number: 2, instruction: "밥을 넣고 섞는다."),
            ],
            personalNotes: "김치를 먼저 볶으면 신맛이 부드러워진다.",
            source: SourceSnapshot(typeName: "직접 작성", urlString: nil, titleOrMemo: "집 버전")
        )
    }
}
#endif

private extension String {
    var trimmedNilIfEmpty: String? {
        let trimmedValue = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}
