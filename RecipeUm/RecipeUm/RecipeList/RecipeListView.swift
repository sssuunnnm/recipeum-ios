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
    @State private var isPresentingNewRecipe = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text("RecipeUm")
                        .font(.largeTitle.bold())

                    Spacer()

                    Button {
                        isPresentingNewRecipe = true
                    } label: {
                        Label("레시피 추가", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.top, 12)

                if recipes.isEmpty {
                    ContentUnavailableView {
                        Label("저장된 레시피 없음", systemImage: "book.closed")
                    } description: {
                        Text("좋아하는 레시피를 내 방식대로 저장해 보세요.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(recipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                RecipeRow(recipe: recipe)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isPresentingNewRecipe) {
                RecipeEditorView(navigationTitle: "레시피 추가") { draft in
                    modelContext.insert(draft.makeRecipe())
                    try? modelContext.save()
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
