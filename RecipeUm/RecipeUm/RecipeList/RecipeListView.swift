//
//  RecipeListView.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import SwiftData
import SwiftUI

struct RecipeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Recipe.updatedAt, order: .reverse) private var recipes: [Recipe]

    var body: some View {
        NavigationStack {
            Group {
                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("저장된 레시피 없음", systemImage: "book.closed")
                    } description: {
                        Text("좋아하는 레시피를 내 방식대로 저장해 보세요.")
                    }
                } else {
                    List {
                        ForEach(recipes) { recipe in
                            NavigationLink {
                                RecipeSummaryView(recipe: recipe)
                            } label: {
                                RecipeRow(recipe: recipe)
                            }
                        }
                    }
                }
            }
            .navigationTitle("RecipeUm")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        IngredientInputView()
                    } label: {
                        Label("재료 입력", systemImage: "square.and.pencil")
                    }
                }
            }
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recipe.title)
                .font(.headline)

            HStack(spacing: 8) {
                if !recipe.servingText.isEmpty {
                    Label(recipe.servingText, systemImage: "person.2")
                }

                if let cookingTimeMinutes = recipe.cookingTimeMinutes {
                    Label("\(cookingTimeMinutes)분", systemImage: "clock")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !recipe.personalNotes.isEmpty {
                Text(recipe.personalNotes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct RecipeSummaryView: View {
    let recipe: Recipe

    var body: some View {
        List {
            Section("기본 정보") {
                LabeledContent("이름", value: recipe.title)

                if !recipe.servingText.isEmpty {
                    LabeledContent("분량", value: recipe.servingText)
                }

                if let cookingTimeMinutes = recipe.cookingTimeMinutes {
                    LabeledContent("조리 시간", value: "\(cookingTimeMinutes)분")
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
    }
}

#Preview {
    RecipeListView()
        .modelContainer(for: [
            Recipe.self,
            IngredientGroup.self,
            RecipeIngredient.self,
            CookingStep.self,
            RecipeSource.self,
        ], inMemory: true)
}
