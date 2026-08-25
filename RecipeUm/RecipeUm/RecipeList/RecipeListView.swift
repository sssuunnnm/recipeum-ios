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
    @State private var searchText = ""
    @State private var selectedCategoryName: String?
    @State private var isFavoritesOnly = false
    @State private var favoriteErrorMessage: String?

    private var filter: RecipeLibraryFilter {
        RecipeLibraryFilter(
            searchText: searchText,
            categoryName: selectedCategoryName,
            isFavoritesOnly: isFavoritesOnly
        )
    }

    private var filteredRecipes: [Recipe] {
        filter.filteredRecipes(from: recipes)
    }

    private var availableCategoryNames: [String] {
        recipes.availableCategoryNames()
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text("RecipeUm")
                        .font(.largeTitle.bold())

                    Spacer()

                    favoriteFilterButton
                    categoryFilterMenu

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
                    } actions: {
                        Button {
                            isPresentingNewRecipe = true
                        } label: {
                            Label("첫 레시피 추가", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    if filteredRecipes.isEmpty {
                        ContentUnavailableView {
                            Label("검색 결과 없음", systemImage: "magnifyingglass")
                        } description: {
                            Text("검색어나 카테고리 필터를 조정해 보세요.")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        List {
                            ForEach(filteredRecipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    RecipeRow(recipe: recipe)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        toggleFavorite(recipe)
                                    } label: {
                                        Label(
                                            recipe.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                                            systemImage: recipe.isFavorite ? "star.slash" : "star"
                                        )
                                    }
                                    .tint(.yellow)
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "레시피 또는 재료 검색")
            .sheet(isPresented: $isPresentingNewRecipe) {
                RecipeEditorView(navigationTitle: "레시피 추가") { draft in
                    let recipe = draft.makeRecipe()
                    modelContext.insert(recipe)

                    do {
                        try modelContext.save()
                    } catch {
                        modelContext.rollback()
                        throw error
                    }
                }
            }
            .alert("즐겨찾기 저장 실패", isPresented: isShowingFavoriteError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(favoriteErrorMessage ?? "다시 시도해 주세요.")
            }
        }
    }

    private var isShowingFavoriteError: Binding<Bool> {
        Binding(
            get: { favoriteErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    favoriteErrorMessage = nil
                }
            }
        )
    }

    private var favoriteFilterButton: some View {
        Button {
            isFavoritesOnly.toggle()
        } label: {
            Label("즐겨찾기만 보기", systemImage: isFavoritesOnly ? "star.fill" : "star")
                .labelStyle(.iconOnly)
        }
        .buttonStyle(.bordered)
        .tint(isFavoritesOnly ? .yellow : nil)
        .accessibilityLabel(isFavoritesOnly ? "전체 레시피 보기" : "즐겨찾기만 보기")
    }

    @ViewBuilder
    private var categoryFilterMenu: some View {
        if !availableCategoryNames.isEmpty || selectedCategoryName != nil {
            Menu {
                Button("전체") {
                    selectedCategoryName = nil
                }

                ForEach(availableCategoryNames, id: \.self) { categoryName in
                    Button(categoryName) {
                        selectedCategoryName = categoryName
                    }
                }
            } label: {
                Label(selectedCategoryName ?? "카테고리 필터", systemImage: "line.3.horizontal.decrease.circle")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel(selectedCategoryName.map { "\($0) 필터 적용 중" } ?? "카테고리 필터")
        }
    }

    private func toggleFavorite(_ recipe: Recipe) {
        recipe.isFavorite.toggle()
        recipe.markUpdated()

        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            favoriteErrorMessage = error.localizedDescription
        }
    }
}

private struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(recipe.title)
                    .font(.headline)

                if recipe.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }

                Spacer()

                if let categoryName = recipe.categoryName, !categoryName.isEmpty {
                    Text(categoryName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: Capsule())
                }
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
