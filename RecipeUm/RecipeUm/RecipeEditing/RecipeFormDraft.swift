//
//  RecipeFormDraft.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct RecipeFormDraft: Equatable {
    private static let defaultIngredientGroupTitle = "기본 재료"

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
        && !ingredientText.trimmed.isEmpty
        && hasValidCookingTime
    }

    var hasValidCookingTime: Bool {
        let value = cookingTimeMinutesText.trimmed
        return value.isEmpty || Int(value) != nil
    }

    init() {}

    init(recipe: Recipe) {
        title = recipe.title
        recipeDescription = recipe.recipeDescription ?? ""
        servingText = recipe.servingText
        cookingTimeMinutesText = recipe.cookingTimeMinutes.map(String.init) ?? ""
        personalNotes = recipe.personalNotes
        categoryName = recipe.categoryName ?? ""
        ingredientText = Self.ingredientText(from: recipe.sortedIngredientGroups)
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

    func apply(
        to recipe: Recipe,
        at date: Date = Date(),
        parser: IngredientParser = IngredientParser()
    ) {
        recipe.title = title.trimmed
        recipe.recipeDescription = recipeDescription.trimmedNilIfEmpty
        recipe.servingText = servingText.trimmed
        recipe.cookingTimeMinutes = cookingTimeMinutes
        recipe.personalNotes = personalNotes.trimmed
        recipe.categoryName = categoryName.trimmedNilIfEmpty
        recipe.ingredientGroups = makeIngredientGroups(parser: parser)
        recipe.cookingSteps = makeCookingSteps()
        recipe.source = makeSource()
        recipe.markUpdated(at: date)
    }

    private var cookingTimeMinutes: Int? {
        Int(cookingTimeMinutesText.trimmed)
    }

    private func makeIngredientGroups(parser: IngredientParser) -> [IngredientGroup] {
        var groups: [IngredientGroup] = []
        var currentTitle = Self.defaultIngredientGroupTitle
        var currentLines: [String] = []

        func appendCurrentGroup() {
            let ingredients = parser
                .parseLines(currentLines.joined(separator: "\n"))
                .enumerated()
                .map { index, parsedIngredient in
                    parsedIngredient.makeIngredient(sortOrder: index)
                }

            guard !ingredients.isEmpty else {
                return
            }

            let group = IngredientGroup(title: currentTitle, sortOrder: groups.count)
            group.ingredients = ingredients
            groups.append(group)
        }

        ingredientText
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmed }
            .forEach { line in
                guard !line.isEmpty else {
                    return
                }

                if let groupTitle = Self.groupTitle(from: line) {
                    appendCurrentGroup()
                    currentTitle = groupTitle
                    currentLines = []
                } else {
                    currentLines.append(line)
                }
            }

        appendCurrentGroup()
        return groups
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

    private static func ingredientText(from groups: [IngredientGroup]) -> String {
        let sortedGroups = groups.filter { !$0.sortedIngredients.isEmpty }

        guard !sortedGroups.isEmpty else {
            return ""
        }

        let shouldIncludeGroupTitles = sortedGroups.count > 1
        || sortedGroups.contains { $0.title != defaultIngredientGroupTitle }

        return sortedGroups
            .map { group in
                let ingredientLines = group.sortedIngredients
                    .map(\.rawText)
                    .joined(separator: "\n")

                guard shouldIncludeGroupTitles else {
                    return ingredientLines
                }

                return "[\(group.title)]\n\(ingredientLines)"
            }
            .joined(separator: "\n\n")
    }

    private static func groupTitle(from line: String) -> String? {
        guard line.hasPrefix("["),
              line.hasSuffix("]")
        else {
            return nil
        }

        let title = line
            .dropFirst()
            .dropLast()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return title.isEmpty ? nil : title
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
