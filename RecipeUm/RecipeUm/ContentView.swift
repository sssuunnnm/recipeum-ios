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
            ContentUnavailableView(
                "RecipeUm",
                systemImage: "book.closed",
                description: Text("좋아하는 레시피를 나만의 것으로.")
            )
            .navigationTitle("RecipeUm")
        }
    }
}

#Preview {
    ContentView()
}
