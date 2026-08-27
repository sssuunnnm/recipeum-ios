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
    @State private var isOptionalInfoExpanded = false
    @State private var isCookingStepsExpanded = false
    @State private var isSourceExpanded = false
    @State private var isNotesExpanded = false
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
        _isOptionalInfoExpanded = State(initialValue: draft.hasBasicDetailValues)
        _isCookingStepsExpanded = State(initialValue: !draft.cookingStepText.trimmedForEditor.isEmpty)
        _isSourceExpanded = State(initialValue: draft.hasSourceValues)
        _isNotesExpanded = State(initialValue: !draft.personalNotes.trimmedForEditor.isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("레시피 이름", text: $draft.title)
                    TextEditor(text: $draft.ingredientText)
                        .frame(minHeight: 140)
                        .accessibilityLabel("재료")
                } header: {
                    Text("필수")
                } footer: {
                    Text("재료는 한 줄에 하나씩 입력합니다. [양념]처럼 적으면 그룹으로 나눌 수 있습니다.")
                }

                Section("선택 정보") {
                    DisclosureGroup("기본 세부 정보", isExpanded: $isOptionalInfoExpanded) {
                        TextField("분량", text: $draft.servingText)
                        TextField("조리 시간(분)", text: $draft.cookingTimeMinutesText)
                            .keyboardType(.numberPad)

                        Picker("카테고리", selection: $draft.categoryName) {
                            ForEach(categoryOptions, id: \.self) { categoryName in
                                Text(categoryName.isEmpty ? "선택 안 함" : categoryName)
                                    .tag(categoryName)
                            }
                        }

                        TextField("간단한 설명", text: $draft.recipeDescription, axis: .vertical)
                            .lineLimit(2...4)
                    }

                    DisclosureGroup("조리 단계", isExpanded: $isCookingStepsExpanded) {
                        TextEditor(text: $draft.cookingStepText)
                            .frame(minHeight: 140)
                            .accessibilityLabel("조리 단계")
                    }

                    DisclosureGroup("출처", isExpanded: $isSourceExpanded) {
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

                    DisclosureGroup("내 메모", isExpanded: $isNotesExpanded) {
                        TextEditor(text: $draft.personalNotes)
                            .frame(minHeight: 100)
                            .accessibilityLabel("내 메모")
                    }
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

private extension RecipeFormDraft {
    var hasBasicDetailValues: Bool {
        !servingText.trimmedForEditor.isEmpty
        || !cookingTimeMinutesText.trimmedForEditor.isEmpty
        || !categoryName.trimmedForEditor.isEmpty
        || !recipeDescription.trimmedForEditor.isEmpty
    }

    var hasSourceValues: Bool {
        sourceType != .other
        || !sourceURLString.trimmedForEditor.isEmpty
        || !sourceTitleOrMemo.trimmedForEditor.isEmpty
    }
}

private extension String {
    var trimmedForEditor: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
