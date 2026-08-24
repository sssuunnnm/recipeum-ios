//
//  ContentView.swift
//  RecipeUm
//
//  Created by 이선민 on 8/24/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    "RecipeUm",
                    systemImage: "book.closed",
                    description: Text("좋아하는 레시피를 나만의 것으로.")
                )

                NavigationLink {
                    IngredientInputView()
                } label: {
                    Label("재료 입력 시작", systemImage: "square.and.pencil")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("RecipeUm")
        }
    }
}

#Preview {
    ContentView()
}
