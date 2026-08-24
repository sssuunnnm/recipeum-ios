//
//  RecipeUmTests.swift
//  RecipeUmTests
//
//  Created by 이선민 on 8/24/26.
//

import Testing
import SwiftData
@testable import RecipeUm

struct RecipeUmTests {
    private let parser = IngredientParser()

    @Test func parsesWeightWithoutWhitespace() {
        let result = parser.parseLine("돼지고기 300g")

        #expect(result.rawText == "돼지고기 300g")
        #expect(result.name == "돼지고기")
        #expect(result.amountText == "300")
        #expect(result.amountValue == 300)
        #expect(result.amountUpperValue == nil)
        #expect(result.unit == "g")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesKoreanHalfExpression() {
        let result = parser.parseLine("양파 반 개")

        #expect(result.rawText == "양파 반 개")
        #expect(result.name == "양파")
        #expect(result.amountText == "반")
        #expect(result.amountValue == 0.5)
        #expect(result.unit == "개")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesRangeWithoutForcingSingleValue() {
        let result = parser.parseLine("계란 2~3개")

        #expect(result.name == "계란")
        #expect(result.amountText == "2~3")
        #expect(result.amountValue == 2)
        #expect(result.amountUpperValue == 3)
        #expect(result.unit == "개")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesTablespoonAmount() {
        let result = parser.parseLine("진간장 2큰술")

        #expect(result.name == "진간장")
        #expect(result.amountText == "2")
        #expect(result.amountValue == 2)
        #expect(result.unit == "큰술")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesNonNumericAmount() {
        let result = parser.parseLine("후추 약간")

        #expect(result.name == "후추")
        #expect(result.amountText == "약간")
        #expect(result.amountValue == nil)
        #expect(result.unit == nil)
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesPreferenceAmount() {
        let result = parser.parseLine("소금 취향껏")

        #expect(result.name == "소금")
        #expect(result.amountText == "취향껏")
        #expect(result.amountValue == nil)
        #expect(result.parseStatus == .parsed)
    }

    @Test func marksUncertainInputForReview() {
        let result = parser.parseLine("대파 흰 부분 손가락 두 마디 정도")

        #expect(result.rawText == "대파 흰 부분 손가락 두 마디 정도")
        #expect(result.name == "대파 흰 부분 손가락 두 마디 정도")
        #expect(result.amountText == nil)
        #expect(result.amountValue == nil)
        #expect(result.unit == nil)
        #expect(result.parseStatus == .needsReview)
    }

    @Test func parsesCommonFraction() {
        let result = parser.parseLine("설탕 1/2큰술")

        #expect(result.name == "설탕")
        #expect(result.amountText == "1/2")
        #expect(result.amountValue == 0.5)
        #expect(result.unit == "큰술")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesUppercaseAsciiUnits() {
        let weight = parser.parseLine("돼지고기 300G")
        let volume = parser.parseLine("물 1L")

        #expect(weight.name == "돼지고기")
        #expect(weight.amountText == "300")
        #expect(weight.unit == "g")
        #expect(weight.parseStatus == .parsed)
        #expect(volume.name == "물")
        #expect(volume.amountText == "1")
        #expect(volume.unit == "L")
        #expect(volume.parseStatus == .parsed)
    }

    @Test func parsesBulletedIngredientLineWhilePreservingRawText() {
        let result = parser.parseLine("- 양파 1개")

        #expect(result.rawText == "- 양파 1개")
        #expect(result.name == "양파")
        #expect(result.amountText == "1")
        #expect(result.amountValue == 1)
        #expect(result.unit == "개")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesNumberedIngredientLineWhilePreservingRawText() {
        let result = parser.parseLine("1. 진간장 2큰술")

        #expect(result.rawText == "1. 진간장 2큰술")
        #expect(result.name == "진간장")
        #expect(result.amountText == "2")
        #expect(result.unit == "큰술")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesIngredientWithTrailingNote() {
        let result = parser.parseLine("대파 1대(흰 부분)")

        #expect(result.rawText == "대파 1대(흰 부분)")
        #expect(result.name == "대파")
        #expect(result.amountText == "1")
        #expect(result.unit == "대")
        #expect(result.parseStatus == .parsed)
    }

    @Test func parsesMultipleNonEmptyLines() {
        let results = parser.parseLines("""
        돼지고기 300g

        후추 약간
        대파 흰 부분 손가락 두 마디 정도
        """)

        #expect(results.count == 3)
        #expect(results[0].name == "돼지고기")
        #expect(results[1].amountText == "약간")
        #expect(results[2].parseStatus == .needsReview)
    }

    @Test func createsEditableIngredientWhilePreservingRawText() {
        let parsed = parser.parseLine("돼지고기 300g")
        let ingredient = parsed.makeIngredient(sortOrder: 0)

        #expect(ingredient.rawText == "돼지고기 300g")
        #expect(ingredient.name == "돼지고기")
        #expect(ingredient.amountText == "300")
        #expect(ingredient.amountValue == 300)
        #expect(ingredient.unit == "g")
        #expect(ingredient.parseStatus == .parsed)
    }

    @Test func buildsIngredientReviewStateFromMultilineInput() {
        var state = IngredientReviewState(inputText: """
        돼지고기 300g
        후추 약간
        대파 흰 부분 손가락 두 마디 정도
        """)

        state.parseInput(using: parser)

        #expect(state.items.count == 3)
        #expect(state.reviewRequiredCount == 1)
        #expect(state.items[0].rawText == "돼지고기 300g")
        #expect(state.items[0].name == "돼지고기")
        #expect(state.items[1].amountText == "약간")
        #expect(state.items[2].rawText == "대파 흰 부분 손가락 두 마디 정도")
        #expect(state.items[2].parseStatus == .needsReview)
    }

    @Test func appliesManualIngredientCorrection() {
        var state = IngredientReviewState(inputText: "대파 흰 부분 손가락 두 마디 정도")
        state.parseInput(using: parser)

        let itemID = state.items[0].id
        state.updateItem(
            id: itemID,
            name: "대파 흰 부분",
            amountText: "2",
            unit: "마디"
        )

        #expect(state.reviewRequiredCount == 0)
        #expect(state.items[0].rawText == "대파 흰 부분 손가락 두 마디 정도")
        #expect(state.items[0].name == "대파 흰 부분")
        #expect(state.items[0].amountText == "2")
        #expect(state.items[0].amountValue == 2)
        #expect(state.items[0].unit == "마디")
        #expect(state.items[0].parseStatus == .parsed)
    }

    @Test func createsIngredientsFromReviewItemsInOrder() {
        var state = IngredientReviewState(inputText: """
        설탕 1/2큰술
        소금 취향껏
        """)

        state.parseInput(using: parser)
        let ingredients = state.makeIngredients()

        #expect(ingredients.count == 2)
        #expect(ingredients[0].rawText == "설탕 1/2큰술")
        #expect(ingredients[0].amountValue == 0.5)
        #expect(ingredients[0].sortOrder == 0)
        #expect(ingredients[1].rawText == "소금 취향껏")
        #expect(ingredients[1].sortOrder == 1)
    }

    @Test @MainActor func exposesChildrenInSortOrder() throws {
        let schema = Schema([
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let recipe = Recipe(title: "김치찌개")
        let laterGroup = IngredientGroup(title: "양념", sortOrder: 1)
        let firstGroup = IngredientGroup(title: "기본 재료", sortOrder: 0)
        let laterStep = CookingStep(sortOrder: 1, instruction: "끓인다.")
        let firstStep = CookingStep(sortOrder: 0, instruction: "재료를 넣는다.")
        let laterIngredient = RecipeIngredient(rawText: "고춧가루 1큰술", name: "고춧가루", sortOrder: 1)
        let firstIngredient = RecipeIngredient(rawText: "김치 300g", name: "김치", sortOrder: 0)

        recipe.ingredientGroups = [laterGroup, firstGroup]
        recipe.cookingSteps = [laterStep, firstStep]
        firstGroup.ingredients = [laterIngredient, firstIngredient]

        container.mainContext.insert(recipe)
        try container.mainContext.save()

        let savedRecipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(savedRecipes.count == 1)
        let savedRecipe = try #require(savedRecipes.first)

        #expect(savedRecipe.sortedIngredientGroups.map(\.title) == ["기본 재료", "양념"])
        #expect(savedRecipe.sortedCookingSteps.map(\.instruction) == ["재료를 넣는다.", "끓인다."])
        #expect(savedRecipe.sortedIngredientGroups.first?.sortedIngredients.map(\.name) == ["김치", "고춧가루"])
    }

    @Test @MainActor func storesRecipeArchiveDataLocally() throws {
        let schema = Schema([
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])

        let recipe = Recipe(
            title: "제육볶음",
            recipeDescription: "매콤한 돼지고기 볶음",
            servingText: "2인분",
            cookingTimeMinutes: 20,
            personalNotes: "우리 집 인덕션에서는 4단계가 적당함"
        )
        let group = IngredientGroup(title: "기본 재료", sortOrder: 0)
        group.ingredients = [
            RecipeIngredient(
                rawText: "돼지고기 300g",
                name: "돼지고기",
                amountText: "300",
                amountValue: 300,
                unit: "g",
                parseStatus: .parsed,
                sortOrder: 0
            )
        ]
        recipe.ingredientGroups = [group]
        recipe.cookingSteps = [
            CookingStep(sortOrder: 0, instruction: "돼지고기를 볶는다.")
        ]
        recipe.source = RecipeSource(
            type: .youtube,
            urlString: "https://example.com/recipe",
            titleOrMemo: "원본 영상"
        )

        container.mainContext.insert(recipe)
        try container.mainContext.save()

        let savedRecipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(savedRecipes.count == 1)
        #expect(savedRecipes[0].title == "제육볶음")
        #expect(savedRecipes[0].servingText == "2인분")
        #expect(savedRecipes[0].ingredientGroups.count == 1)
        #expect(savedRecipes[0].ingredientGroups[0].ingredients[0].rawText == "돼지고기 300g")
        #expect(savedRecipes[0].cookingSteps[0].instruction == "돼지고기를 볶는다.")
        #expect(savedRecipes[0].source?.type == .youtube)
        #expect(savedRecipes[0].source?.urlString == "https://example.com/recipe")
    }
}
