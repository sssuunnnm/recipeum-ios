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

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text(recipe.title)
                        .font(.title2.bold())

                    if let recipeDescription = recipe.recipeDescription, !recipeDescription.isEmpty {
                        Text(recipeDescription)
                            .foregroundStyle(.secondary)
                    }

                    if hasSummaryValues {
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
                }
                .padding(.vertical, 4)
            }

            Section("재료") {
                if let ingredientGroup = recipe.sortedIngredientGroups.first {
                    ForEach(ingredientGroup.sortedIngredients) { ingredient in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)

                            HStack(spacing: 6) {
                                if let amountText = ingredient.amountText {
                                    Text(amountText)
                                }

                                if let unit = ingredient.unit {
                                    Text(unit)
                                }

                                if ingredient.amountText != nil || ingredient.unit != nil {
                                    Text("·")
                                }

                                Text(ingredient.rawText)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text("저장된 재료 없음")
                        .foregroundStyle(.secondary)
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
                replaceDetailFields(with: draft)
            }
        }
        .confirmationDialog(
            "이 레시피를 삭제할까요?",
            isPresented: $isPresentingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                modelContext.delete(recipe)
                try? modelContext.save()
                dismiss()
            }

            Button("취소", role: .cancel) {}
        }
    }

    private var hasSummaryValues: Bool {
        !recipe.servingText.isEmpty
        || recipe.cookingTimeMinutes != nil
        || recipe.categoryName?.isEmpty == false
    }

    private func replaceDetailFields(with draft: RecipeFormDraft) {
        recipe.ingredientGroups.forEach(modelContext.delete)
        recipe.cookingSteps.forEach(modelContext.delete)

        if let source = recipe.source {
            modelContext.delete(source)
        }

        draft.apply(to: recipe)
        try? modelContext.save()
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
