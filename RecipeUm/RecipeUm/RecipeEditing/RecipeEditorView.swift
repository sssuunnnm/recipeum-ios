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
    let onSave: (RecipeFormDraft) throws -> Void

    @State private var draft: RecipeFormDraft
    @State private var saveErrorMessage: String?

    private var categoryOptions: [String] {
        RecipeCategoryCatalog.editorOptions(including: draft.categoryName)
    }

    init(
        navigationTitle: String,
        draft: RecipeFormDraft = RecipeFormDraft(),
        onSave: @escaping (RecipeFormDraft) throws -> Void
    ) {
        self.navigationTitle = navigationTitle
        self.onSave = onSave
        _draft = State(initialValue: draft)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("레시피 이름 *", text: $draft.title)
                    Text("재료 *")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    PlaceholderTextEditor(
                        text: $draft.ingredientText,
                        placeholder: "[양념]\n간장 2큰술\n설탕 1큰술\n\n재료는 한 줄에 하나씩 입력해요"
                    )
                        .frame(minHeight: 140)
                        .accessibilityLabel("재료")
                } header: {
                    Text("기본 정보")
                } footer: {
                    Text("* 표시된 항목은 저장에 필요해요.")
                }

                Section {
                    TextField("분량", text: $draft.servingText)
                    TextField("조리 시간(분)", text: $draft.cookingTimeMinutesText)
                        .keyboardType(.numberPad)

                    Picker("카테고리", selection: $draft.categoryName) {
                        ForEach(categoryOptions, id: \.self) { categoryName in
                            Text(categoryName.isEmpty ? "선택 안 함" : categoryName)
                                .tag(categoryName)
                        }
                    }

                    TextField("한 줄 요약", text: $draft.recipeDescription, axis: .vertical)
                        .lineLimit(1...2)
                } header: {
                    Text("상단 정보")
                } footer: {
                    Text("레시피 상세 화면 맨 위에 표시돼요.")
                }

                Section("조리 단계") {
                    PlaceholderTextEditor(
                        text: $draft.cookingStepText,
                        placeholder: "물을 끓여요\n재료를 넣고 5분 끓여요\n\nEnter로 구분하면 번호가 자동으로 표시돼요"
                    )
                        .frame(minHeight: 140)
                        .accessibilityLabel("조리 단계")
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
                    TextField(draft.sourceType.titleLabel, text: $draft.sourceTitleOrMemo)
                }

                Section("내 메모") {
                    TextEditor(text: $draft.personalNotes)
                        .frame(minHeight: 100)
                        .accessibilityLabel("내 메모")
                }
            }
            .scrollContentBackground(.hidden)
            .background(RecipeTheme.background)
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
                        save()
                    }
                    .tint(RecipeTheme.sage)
                    .disabled(!draft.canSave)
                }
            }
            .alert("저장 실패", isPresented: isShowingSaveError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(saveErrorMessage ?? "다시 시도해 주세요.")
            }
        }
    }

    private var isShowingSaveError: Binding<Bool> {
        Binding(
            get: { saveErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    saveErrorMessage = nil
                }
            }
        )
    }

    private func save() {
        do {
            try onSave(draft)
            dismiss()
        } catch {
            saveErrorMessage = error.localizedDescription
        }
    }
}

#Preview {
    RecipeEditorView(navigationTitle: "레시피 추가") { _ in }
}

private struct PlaceholderTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)

            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
        }
    }
}
