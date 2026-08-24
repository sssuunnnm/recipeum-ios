//
//  IngredientInputView.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import SwiftUI

struct IngredientInputView: View {
    @State private var reviewState = IngredientReviewState()
    @State private var editingItem: IngredientReviewItem?
    @FocusState private var isIngredientInputFocused: Bool

    private let exampleText = """
    돼지고기 300g
    양파 반 개
    대파 1대
    진간장 2큰술
    설탕 1큰술
    후추 약간
    대파 흰 부분 손가락 두 마디 정도
    """

    var body: some View {
        Form {
            Section {
                TextEditor(text: $reviewState.inputText)
                    .frame(minHeight: 180)
                    .focused($isIngredientInputFocused)
                    .accessibilityLabel("재료 입력")

                HStack {
                    Button {
                        reviewState.inputText = exampleText
                        isIngredientInputFocused = false
                        reviewState.parseInput()
                    } label: {
                        Label("예시", systemImage: "text.badge.plus")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button {
                        isIngredientInputFocused = false
                        reviewState.parseInput()
                    } label: {
                        Label("파싱", systemImage: "wand.and.sparkles")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(reviewState.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            } header: {
                Text("재료 입력")
            } footer: {
                Text("여러 줄을 붙여넣으면 비어 있지 않은 각 줄을 하나의 재료 후보로 봅니다.")
            }

            Section {
                if reviewState.hasReviewItems {
                    ForEach(reviewState.items) { item in
                        IngredientReviewRow(item: item) {
                            editingItem = item
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "파싱 결과 없음",
                        systemImage: "list.bullet.rectangle",
                        description: Text("재료를 입력하고 파싱을 실행하세요.")
                    )
                }
            } header: {
                HStack {
                    Text("검토")
                    Spacer()
                    if reviewState.hasReviewItems {
                        Text("\(reviewState.reviewRequiredCount)개 확인 필요")
                            .font(.caption)
                            .foregroundStyle(reviewCountColor)
                    }
                }
            }
        }
        .navigationTitle("재료 입력")
        .sheet(item: $editingItem) { item in
            IngredientCorrectionView(item: item) { name, amountText, unit in
                reviewState.updateItem(
                    id: item.id,
                    name: name,
                    amountText: amountText,
                    unit: unit
                )
            }
        }
    }

    private var reviewCountColor: Color {
        reviewState.reviewRequiredCount == 0 ? .secondary : .orange
    }
}

private struct IngredientReviewRow: View {
    let item: IngredientReviewItem
    let onEdit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.name.isEmpty ? item.rawText : item.name)
                    .font(.headline)

                Spacer()

                Label(statusTitle, systemImage: statusIcon)
                    .font(.caption)
                    .foregroundStyle(item.needsReview ? .orange : .secondary)
            }

            Text(item.rawText)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if let amountText = item.amountText {
                    LabeledContent("수량", value: amountText)
                }

                if let unit = item.unit {
                    LabeledContent("단위", value: unit)
                }

                Spacer()

                Button {
                    onEdit()
                } label: {
                    Label("수정", systemImage: "pencil")
                        .labelStyle(.iconOnly)
                }
                .buttonStyle(.borderless)
            }
            .font(.caption)
        }
        .padding(.vertical, 4)
    }

    private var statusTitle: String {
        item.needsReview ? "확인 필요" : "파싱됨"
    }

    private var statusIcon: String {
        item.needsReview ? "exclamationmark.circle" : "checkmark.circle"
    }
}

private struct IngredientCorrectionView: View {
    @Environment(\.dismiss) private var dismiss

    let item: IngredientReviewItem
    let onSave: (_ name: String, _ amountText: String?, _ unit: String?) -> Void

    @State private var name: String
    @State private var amountText: String
    @State private var unit: String

    init(
        item: IngredientReviewItem,
        onSave: @escaping (_ name: String, _ amountText: String?, _ unit: String?) -> Void
    ) {
        self.item = item
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _amountText = State(initialValue: item.amountText ?? "")
        _unit = State(initialValue: item.unit ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("원문") {
                    Text(item.rawText)
                        .foregroundStyle(.secondary)
                }

                Section("구조화 필드") {
                    TextField("재료명", text: $name)
                    TextField("수량", text: $amountText)
                        .keyboardType(.numbersAndPunctuation)
                    TextField("단위", text: $unit)
                }
            }
            .navigationTitle("재료 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        onSave(name, amountText, unit)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IngredientInputView()
    }
}
