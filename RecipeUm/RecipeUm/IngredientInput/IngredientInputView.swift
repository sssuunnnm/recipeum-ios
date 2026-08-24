//
//  IngredientInputView.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import SwiftUI

struct IngredientInputView: View {
    @State private var reviewState = IngredientReviewState()

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
                    .accessibilityLabel("재료 입력")

                HStack {
                    Button {
                        reviewState.inputText = exampleText
                        reviewState.parseInput()
                    } label: {
                        Label("예시", systemImage: "text.badge.plus")
                    }
                    .buttonStyle(.bordered)

                    Spacer()

                    Button {
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
                        IngredientReviewRow(item: item)
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
    }

    private var reviewCountColor: Color {
        reviewState.reviewRequiredCount == 0 ? .secondary : .orange
    }
}

private struct IngredientReviewRow: View {
    let item: IngredientReviewItem

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

#Preview {
    NavigationStack {
        IngredientInputView()
    }
}
