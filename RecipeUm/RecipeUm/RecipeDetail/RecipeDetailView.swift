//
//  RecipeDetailView.swift
//  RecipeUm
//
//  Created by Codex on 8/25/26.
//

import SwiftData
import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let recipe: Recipe

    @State private var isPresentingEditor = false
    @State private var isPresentingDeleteConfirmation = false
    @State private var deleteErrorMessage: String?

    var body: some View {
        List {
            if hasHeaderContent {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        if let recipeDescription = recipe.recipeDescription, !recipeDescription.isEmpty {
                            Text(recipeDescription)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 8) {
                            if !recipe.servingText.isEmpty {
                                Label(recipe.servingText, systemImage: "person.2")
                            }

                            if let cookingTimeMinutes = recipe.cookingTimeMinutes {
                                Label("\(cookingTimeMinutes)분", systemImage: "clock")
                            }

                            if let categoryName = recipe.categoryName, !categoryName.isEmpty {
                                Label(categoryName, systemImage: "tag")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("재료") {
                if recipe.sortedIngredientGroups.isEmpty {
                    Text("저장된 재료 없음")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(recipe.sortedIngredientGroups) { ingredientGroup in
                        if shouldShowIngredientGroupTitle {
                            Text(ingredientGroup.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        ForEach(ingredientGroup.sortedIngredients) { ingredient in
                            IngredientLineView(ingredient: ingredient)
                        }
                    }
                }
            }

            Section("조리 단계") {
                if recipe.sortedCookingSteps.isEmpty {
                    Text("저장된 조리 단계 없음")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(Array(recipe.sortedCookingSteps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .frame(width: 24, height: 24)
                                .background(.thinMaterial, in: Circle())

                            Text(step.instruction)
                        }
                    }
                }
            }

            if let source = recipe.source {
                Section("출처") {
                    LabeledContent("종류", value: source.type.displayName)

                    if let urlString = source.urlString {
                        LabeledContent("URL", value: urlString)
                    }

                    if !source.titleOrMemo.isEmpty {
                        LabeledContent("메모", value: source.titleOrMemo)
                    }
                }
            }

            if !recipe.personalNotes.isEmpty {
                Section("내 메모") {
                    Text(recipe.personalNotes)
                }
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        isPresentingEditor = true
                    } label: {
                        Label("수정", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        isPresentingDeleteConfirmation = true
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Label("더 보기", systemImage: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingEditor) {
            RecipeEditorView(
                navigationTitle: "레시피 수정",
                draft: RecipeFormDraft(recipe: recipe)
            ) { draft in
                try replaceDetailFields(with: draft)
            }
        }
        .confirmationDialog(
            "이 레시피를 삭제할까요?",
            isPresented: $isPresentingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                deleteRecipe()
            }

            Button("취소", role: .cancel) {}
        }
        .alert("삭제 실패", isPresented: isShowingDeleteError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(deleteErrorMessage ?? "다시 시도해 주세요.")
        }
    }

    private var isShowingDeleteError: Binding<Bool> {
        Binding(
            get: { deleteErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    deleteErrorMessage = nil
                }
            }
        )
    }

    private func deleteRecipe() {
        do {
            modelContext.delete(recipe)
            try modelContext.save()
            dismiss()
        } catch {
            modelContext.rollback()
            deleteErrorMessage = error.localizedDescription
        }
    }

    private var hasHeaderContent: Bool {
        recipe.recipeDescription?.isEmpty == false || hasSummaryValues
    }

    private var hasSummaryValues: Bool {
        !recipe.servingText.isEmpty
        || recipe.cookingTimeMinutes != nil
        || recipe.categoryName?.isEmpty == false
    }

    private var shouldShowIngredientGroupTitle: Bool {
        recipe.sortedIngredientGroups.count > 1
        || recipe.sortedIngredientGroups.contains { $0.title != "기본 재료" }
    }

    private func replaceDetailFields(with draft: RecipeFormDraft) throws {
        do {
            recipe.ingredientGroups.forEach(modelContext.delete)
            recipe.cookingSteps.forEach(modelContext.delete)

            if let source = recipe.source {
                modelContext.delete(source)
            }

            draft.apply(to: recipe)
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }
}

private struct IngredientLineView: View {
    let ingredient: RecipeIngredient

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ingredientDisplayText)

            if shouldShowRawText {
                Text(ingredient.rawText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var ingredientDisplayText: AttributedString {
        var text = AttributedString(ingredient.name)
        text.font = .body.bold()

        if !amountAndUnitText.isEmpty {
            var amountText = AttributedString(" \(amountAndUnitText)")
            amountText.font = .body
            text.append(amountText)
        }

        return text
    }

    private var amountAndUnitText: String {
        [ingredient.amountText, ingredient.unit]
            .compactMap { value in
                let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmedValue?.isEmpty == false ? trimmedValue : nil
            }
            .joined()
    }

    private var shouldShowRawText: Bool {
        normalized(ingredient.rawText) != normalized("\(ingredient.name)\(amountAndUnitText)")
    }

    private func normalized(_ text: String) -> String {
        text
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(title: "김치볶음밥"))
    }
    .modelContainer(for: [
        Recipe.self,
        IngredientGroup.self,
        RecipeIngredient.self,
        CookingStep.self,
        RecipeSource.self,
    ], inMemory: true)
}
