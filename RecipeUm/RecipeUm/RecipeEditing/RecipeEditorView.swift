//
//  RecipeEditorView.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import SwiftUI

struct RecipeEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let navigationTitle: String
    let onSave: (RecipeFormDraft) -> Void

    @State private var draft: RecipeFormDraft

    init(
        navigationTitle: String,
        draft: RecipeFormDraft = RecipeFormDraft(),
        onSave: @escaping (RecipeFormDraft) -> Void
    ) {
        self.navigationTitle = navigationTitle
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("레시피 이름", text: $draft.title)
                    TextField("분량", text: $draft.servingText)
                    TextField("조리 시간(분)", text: $draft.cookingTimeMinutesText)
                        .keyboardType(.numberPad)
                    TextField("카테고리", text: $draft.categoryName)
                }

                Section("소개") {
                    TextField("간단한 설명", text: $draft.recipeDescription, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section {
                    TextEditor(text: $draft.ingredientText)
                        .frame(minHeight: 140)
                        .accessibilityLabel("재료")
                } header: {
                    Text("재료")
                } footer: {
                    Text("한 줄에 하나씩 입력하면 저장할 때 구조화된 재료로 보관됩니다.")
                }

                Section {
                    TextEditor(text: $draft.cookingStepText)
                        .frame(minHeight: 140)
                        .accessibilityLabel("조리 단계")
                } header: {
                    Text("조리 단계")
                } footer: {
                    Text("한 줄에 하나씩 입력한 순서대로 저장됩니다.")
                }

                Section("출처") {
                    Picker("종류", selection: $draft.sourceType) {
                        ForEach(RecipeSourceType.allCases, id: \.self) { sourceType in
                            Text(sourceType.displayName).tag(sourceType)
                        }
                    }
                    TextField("URL", text: $draft.sourceURLString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("제목 또는 메모", text: $draft.sourceTitleOrMemo)
                }

                Section("내 메모") {
                    TextEditor(text: $draft.personalNotes)
                        .frame(minHeight: 100)
                        .accessibilityLabel("내 메모")
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(draft)
                        dismiss()
                    }
                    .disabled(!draft.canSave)
                }
            }
        }
    }
}

#Preview {
    RecipeEditorView(navigationTitle: "레시피 추가") { _ in }
}
