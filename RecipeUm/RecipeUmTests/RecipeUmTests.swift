//
//  RecipeUmTests.swift
//  RecipeUmTests
//
//  Created by 이선민 on 8/24/26.
//

import Testing
import SwiftData
@testable import RecipeUm

@Suite(.serialized)
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

    @Test func parsesKoreanMetricUnits() {
        let weight = parser.parseLine("소고기 100그램")
        let volume = parser.parseLine("물 500밀리리터")
        let liter = parser.parseLine("육수 1리터")

        #expect(weight.name == "소고기")
        #expect(weight.amountText == "100")
        #expect(weight.amountValue == 100)
        #expect(weight.unit == "g")
        #expect(weight.parseStatus == .parsed)
        #expect(volume.name == "물")
        #expect(volume.amountText == "500")
        #expect(volume.unit == "ml")
        #expect(volume.parseStatus == .parsed)
        #expect(liter.name == "육수")
        #expect(liter.amountText == "1")
        #expect(liter.unit == "L")
        #expect(liter.parseStatus == .parsed)
    }

    @Test func parsesCommonKoreanUnitAliases() {
        let kilo = parser.parseLine("소고기 1키로")
        let kilogram = parser.parseLine("돼지고기 2킬로")
        let gram = parser.parseLine("소금 5그람")
        let milli = parser.parseLine("물 500미리")
        let milliliter = parser.parseLine("우유 200밀리")

        #expect(kilo.name == "소고기")
        #expect(kilo.amountText == "1")
        #expect(kilo.unit == "kg")
        #expect(kilo.parseStatus == .parsed)
        #expect(kilogram.name == "돼지고기")
        #expect(kilogram.amountText == "2")
        #expect(kilogram.unit == "kg")
        #expect(kilogram.parseStatus == .parsed)
        #expect(gram.name == "소금")
        #expect(gram.amountText == "5")
        #expect(gram.unit == "g")
        #expect(gram.parseStatus == .parsed)
        #expect(milli.name == "물")
        #expect(milli.amountText == "500")
        #expect(milli.unit == "ml")
        #expect(milli.parseStatus == .parsed)
        #expect(milliliter.name == "우유")
        #expect(milliliter.amountText == "200")
        #expect(milliliter.unit == "ml")
        #expect(milliliter.parseStatus == .parsed)
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

    @Test func preservesRangeAmountValuesWhenCorrectionKeepsAmountText() {
        var state = IngredientReviewState(inputText: "계란 2~3개")
        state.parseInput(using: parser)

        let itemID = state.items[0].id
        state.updateItem(
            id: itemID,
            name: "달걀",
            amountText: "2~3",
            unit: "개"
        )

        let ingredient = state.makeIngredients()[0]

        #expect(ingredient.rawText == "계란 2~3개")
        #expect(ingredient.name == "달걀")
        #expect(ingredient.amountText == "2~3")
        #expect(ingredient.amountValue == 2)
        #expect(ingredient.amountUpperValue == 3)
        #expect(ingredient.unit == "개")
        #expect(ingredient.parseStatus == .parsed)
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

    @Test @MainActor func createsRecipeFromDraftAndReopensSavedDetailFields() throws {
        let schema = Schema([
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let draft = RecipeFormDraft(
            title: "김치볶음밥",
            recipeDescription: "남은 밥으로 만드는 한 그릇",
            servingText: "1인분",
            cookingTimeMinutesText: "15",
            personalNotes: "김치를 충분히 볶는다.",
            categoryName: "밥",
            ingredientText: """
            밥 1공기
            김치 100그램
            계란 1개
            """,
            cookingStepText: """
            김치를 볶는다.
            밥을 넣고 섞는다.
            계란을 올린다.
            """,
            sourceType: .personal,
            sourceTitleOrMemo: "집에서 적어둔 버전"
        )

        container.mainContext.insert(draft.makeRecipe())
        try container.mainContext.save()

        let savedRecipes = try container.mainContext.fetch(FetchDescriptor<Recipe>())

        #expect(savedRecipes.count == 1)
        let savedRecipe = try #require(savedRecipes.first)
        let ingredientGroup = try #require(savedRecipe.sortedIngredientGroups.first)

        #expect(savedRecipe.title == "김치볶음밥")
        #expect(savedRecipe.recipeDescription == "남은 밥으로 만드는 한 그릇")
        #expect(savedRecipe.servingText == "1인분")
        #expect(savedRecipe.cookingTimeMinutes == 15)
        #expect(savedRecipe.personalNotes == "김치를 충분히 볶는다.")
        #expect(savedRecipe.categoryName == "밥")
        #expect(ingredientGroup.title == "기본 재료")
        #expect(ingredientGroup.sortedIngredients.map(\.rawText) == ["밥 1공기", "김치 100그램", "계란 1개"])
        #expect(ingredientGroup.sortedIngredients[1].unit == "g")
        #expect(savedRecipe.sortedCookingSteps.map(\.instruction) == ["김치를 볶는다.", "밥을 넣고 섞는다.", "계란을 올린다."])
        #expect(savedRecipe.source?.type == .personal)
        #expect(savedRecipe.source?.urlString == nil)
        #expect(savedRecipe.source?.titleOrMemo == "집에서 적어둔 버전")

        let reopenedDraft = RecipeFormDraft(recipe: savedRecipe)

        #expect(reopenedDraft.title == "김치볶음밥")
        #expect(reopenedDraft.ingredientText == "밥 1공기\n김치 100그램\n계란 1개")
        #expect(reopenedDraft.cookingStepText == "김치를 볶는다.\n밥을 넣고 섞는다.\n계란을 올린다.")
        #expect(reopenedDraft.sourceType == .personal)
        #expect(reopenedDraft.sourceTitleOrMemo == "집에서 적어둔 버전")
    }

    @Test func requiresTitleAndIngredientsBeforeSavingRecipeDraft() {
        #expect(!RecipeFormDraft(title: "김치볶음밥").canSave)
        #expect(!RecipeFormDraft(title: "", ingredientText: "밥 1공기").canSave)
        #expect(!RecipeFormDraft(title: "김치볶음밥", cookingTimeMinutesText: "15분", ingredientText: "밥 1공기").canSave)
        #expect(!RecipeFormDraft(title: "김치볶음밥", cookingTimeMinutesText: "abc", ingredientText: "밥 1공기").canSave)
        #expect(RecipeFormDraft(title: "김치볶음밥", ingredientText: "밥 1공기").canSave)
        #expect(RecipeFormDraft(title: "김치볶음밥", cookingTimeMinutesText: "15", ingredientText: "밥 1공기").canSave)
    }

    @Test @MainActor func preservesIngredientGroupBoundariesInRecipeDraft() throws {
        let schema = Schema([
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let seasoningGroup = IngredientGroup(title: "양념", sortOrder: 0)
        seasoningGroup.ingredients = [
            RecipeIngredient(rawText: "고추장 2스푼", name: "고추장", amountText: "2", unit: "스푼", parseStatus: .parsed, sortOrder: 0),
            RecipeIngredient(rawText: "설탕 1스푼", name: "설탕", amountText: "1", unit: "스푼", parseStatus: .parsed, sortOrder: 1),
        ]

        let toppingGroup = IngredientGroup(title: "토핑", sortOrder: 1)
        toppingGroup.ingredients = [
            RecipeIngredient(rawText: "참기름 1/2스푼", name: "참기름", amountText: "1/2", unit: "스푼", parseStatus: .parsed, sortOrder: 0),
        ]

        let recipe = Recipe(title: "비빔만두")
        recipe.ingredientGroups = [toppingGroup, seasoningGroup]
        container.mainContext.insert(recipe)
        try container.mainContext.save()

        let draft = RecipeFormDraft(recipe: recipe)

        #expect(draft.ingredientText == """
        [양념]
        고추장 2스푼
        설탕 1스푼

        [토핑]
        참기름 1/2스푼
        """)

        let remadeRecipe = draft.makeRecipe()
        container.mainContext.insert(remadeRecipe)
        try container.mainContext.save()

        #expect(remadeRecipe.sortedIngredientGroups.map(\.title) == ["양념", "토핑"])
        #expect(remadeRecipe.sortedIngredientGroups[0].sortedIngredients.map(\.rawText) == ["고추장 2스푼", "설탕 1스푼"])
        #expect(remadeRecipe.sortedIngredientGroups[1].sortedIngredients.map(\.rawText) == ["참기름 1/2스푼"])
    }

    @Test @MainActor func appliesDraftChangesToExistingRecipe() throws {
        let schema = Schema([
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let recipe = RecipeFormDraft(
            title: "된장찌개",
            ingredientText: "두부 1모",
            cookingStepText: "끓인다.",
            sourceType: .personal,
            sourceTitleOrMemo: "기본 버전"
        ).makeRecipe()

        container.mainContext.insert(recipe)
        try container.mainContext.save()

        let updateDraft = RecipeFormDraft(
            title: "차돌 된장찌개",
            servingText: "2인분",
            cookingTimeMinutesText: "25",
            personalNotes: "차돌은 마지막에 넣는다.",
            ingredientText: """
            차돌박이 150그램
            두부 1모
            """,
            cookingStepText: """
            육수를 끓인다.
            재료를 넣는다.
            """,
            sourceType: .blog,
            sourceURLString: "https://example.com/doenjang",
            sourceTitleOrMemo: "참고 레시피"
        )

        updateDraft.apply(to: recipe)
        try container.mainContext.save()

        let savedRecipe = try #require(try container.mainContext.fetch(FetchDescriptor<Recipe>()).first)
        let ingredientGroup = try #require(savedRecipe.sortedIngredientGroups.first)

        #expect(savedRecipe.title == "차돌 된장찌개")
        #expect(savedRecipe.servingText == "2인분")
        #expect(savedRecipe.cookingTimeMinutes == 25)
        #expect(savedRecipe.personalNotes == "차돌은 마지막에 넣는다.")
        #expect(ingredientGroup.sortedIngredients.map(\.rawText) == ["차돌박이 150그램", "두부 1모"])
        #expect(ingredientGroup.sortedIngredients.first?.unit == "g")
        #expect(savedRecipe.sortedCookingSteps.map(\.instruction) == ["육수를 끓인다.", "재료를 넣는다."])
        #expect(savedRecipe.source?.type == .blog)
        #expect(savedRecipe.source?.urlString == "https://example.com/doenjang")
        #expect(savedRecipe.source?.titleOrMemo == "참고 레시피")
    }
}

private extension RecipeFormDraft {
    init(
        title: String,
        recipeDescription: String = "",
        servingText: String = "",
        cookingTimeMinutesText: String = "",
        personalNotes: String = "",
        categoryName: String = "",
        ingredientText: String = "",
        cookingStepText: String = "",
        sourceType: RecipeSourceType = .other,
        sourceURLString: String = "",
        sourceTitleOrMemo: String = ""
    ) {
        self.init()
        self.title = title
        self.recipeDescription = recipeDescription
        self.servingText = servingText
        self.cookingTimeMinutesText = cookingTimeMinutesText
        self.personalNotes = personalNotes
        self.categoryName = categoryName
        self.ingredientText = ingredientText
        self.cookingStepText = cookingStepText
        self.sourceType = sourceType
        self.sourceURLString = sourceURLString
        self.sourceTitleOrMemo = sourceTitleOrMemo
    }
}
