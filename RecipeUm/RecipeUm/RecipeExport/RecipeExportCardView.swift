//
//  RecipeExportCardView.swift
//  RecipeUm
//
//  Created by Codex on 8/27/26.
//

import SwiftUI

struct RecipeExportCardView: View {
    let snapshot: RecipeExportSnapshot
    let template: RecipeExportTemplate

    var body: some View {
        switch template {
        case .receipt:
            ReceiptRecipeExportCard(snapshot: snapshot)
        case .memo:
            MemoRecipeExportCard(snapshot: snapshot)
        case .card:
            RecipeIndexExportCard(snapshot: snapshot)
        }
    }
}

private struct ReceiptRecipeExportCard: View {
    let snapshot: RecipeExportSnapshot
    @ScaledMetric(relativeTo: .body) private var brandFontSize = 18
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize = 32
    @ScaledMetric(relativeTo: .body) private var descriptionFontSize = 16
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 16
    @ScaledMetric(relativeTo: .subheadline) private var groupTitleFontSize = 16
    @ScaledMetric(relativeTo: .caption) private var sectionTitleFontSize = 15
    @ScaledMetric(relativeTo: .body) private var horizontalPadding = 42
    @ScaledMetric(relativeTo: .body) private var verticalPadding = 28

    var body: some View {
        VStack(alignment: .leading, spacing: 17) {
            VStack(spacing: 8) {
                Text("RECIPE:UM")
                    .font(.system(size: brandFontSize, weight: .bold, design: .monospaced))

                Text(snapshot.title)
                    .font(.system(size: titleFontSize, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                if let recipeDescription = snapshot.recipeDescription {
                    Text(recipeDescription)
                        .font(.system(size: descriptionFontSize, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
            }

            DashedDivider()

            if hasMetadata {
                metadataRows
                DashedDivider()
            }

            ingredients

            if !snapshot.cookingSteps.isEmpty {
                DashedDivider()
                cookingSteps
            }

            if let personalNotes = snapshot.personalNotes {
                DashedDivider()
                textSection(title: "내 메모", text: personalNotes)
            }

            if let source = snapshot.source, source.hasDisplayContent {
                DashedDivider()
                sourceSection(source)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(Color.white)
        .foregroundStyle(Color(red: 0.16, green: 0.14, blue: 0.12))
        .background(ReceiptShadowBackground())
    }

    private var metadataRows: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !snapshot.servingText.isEmpty {
                metadataRow(label: "분량", value: snapshot.servingText)
            }

            if let cookingTimeText = snapshot.cookingTimeText {
                metadataRow(label: "시간", value: cookingTimeText)
            }

            if let categoryName = snapshot.categoryName {
                metadataRow(label: "분류", value: categoryName)
            }
        }
        .font(.system(size: bodyFontSize, design: .monospaced))
    }

    private func metadataRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }

    private var ingredients: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle("재료")

            ForEach(snapshot.ingredientGroups) { group in
                VStack(alignment: .leading, spacing: 8) {
                    if shouldShowIngredientGroupTitle {
                        Text(group.title)
                            .font(.system(size: groupTitleFontSize, weight: .bold, design: .monospaced))
                    }

                    ForEach(group.ingredients) { ingredient in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("-")
                            Text(ingredient.rawText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .font(.system(size: bodyFontSize, design: .monospaced))
    }

    private var cookingSteps: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("조리 단계")

            ForEach(snapshot.cookingSteps) { step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(step.number).")
                        .frame(width: 34, alignment: .leading)
                    Text(step.instruction)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .font(.system(size: bodyFontSize, design: .monospaced))
    }

    private func textSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionTitle(title)
            Text(text)
                .font(.system(size: bodyFontSize, design: .monospaced))
        }
    }

    private func sourceSection(_ source: RecipeExportSnapshot.SourceSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("출처")
            metadataRow(label: "종류", value: source.typeName)
            if let titleOrMemo = source.titleOrMemo {
                metadataRow(label: "메모", value: titleOrMemo)
            }
            if let urlString = source.urlString {
                metadataRow(label: "URL", value: urlString)
            }
        }
        .font(.system(size: bodyFontSize, design: .monospaced))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: sectionTitleFontSize, weight: .bold, design: .monospaced))
            .tracking(1.4)
    }

    private var shouldShowIngredientGroupTitle: Bool {
        snapshot.ingredientGroups.count > 1
        || snapshot.ingredientGroups.contains { $0.title != "기본 재료" }
    }

    private var hasMetadata: Bool {
        !snapshot.servingText.isEmpty
        || snapshot.cookingTimeText != nil
        || snapshot.categoryName != nil
    }
}

private struct MemoRecipeExportCard: View {
    let snapshot: RecipeExportSnapshot
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize = 34
    @ScaledMetric(relativeTo: .title3) private var descriptionFontSize = 18
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 18
    @ScaledMetric(relativeTo: .subheadline) private var metadataFontSize = 15
    @ScaledMetric(relativeTo: .subheadline) private var urlFontSize = 16
    @ScaledMetric(relativeTo: .body) private var leadingPadding = 74
    @ScaledMetric(relativeTo: .body) private var trailingPadding = 44
    @ScaledMetric(relativeTo: .body) private var verticalPadding = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text(snapshot.title)
                    .font(.system(size: titleFontSize, weight: .bold, design: .rounded))

                if let recipeDescription = snapshot.recipeDescription {
                    Text(recipeDescription)
                        .font(.system(size: descriptionFontSize))
                        .foregroundStyle(.secondary)
                }
            }

            if hasMetadata {
                metadata
            }

            exportSection("재료") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(snapshot.ingredientGroups) { group in
                        VStack(alignment: .leading, spacing: 8) {
                            if shouldShowIngredientGroupTitle {
                                Text(group.title)
                                    .font(.headline)
                                    .foregroundStyle(RecipeTheme.sage)
                            }

                            ForEach(group.ingredients) { ingredient in
                                Text("• \(ingredient.rawText)")
                            }
                        }
                    }
                }
            }

            if !snapshot.cookingSteps.isEmpty {
                exportSection("조리 단계") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(snapshot.cookingSteps) { step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(step.number)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 26, height: 26)
                                    .background(RecipeTheme.sage, in: Circle())

                                Text(step.instruction)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }

            if let personalNotes = snapshot.personalNotes {
                exportSection("내 메모") {
                    Text(personalNotes)
                }
            }

            if let source = snapshot.source, source.hasDisplayContent {
                exportSection("출처") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(source.typeName)
                        if let titleOrMemo = source.titleOrMemo {
                            Text(titleOrMemo)
                        }
                        if let urlString = source.urlString {
                            Text(urlString)
                                .font(.system(size: urlFontSize, design: .monospaced))
                        }
                    }
                }
            }
        }
        .font(.system(size: bodyFontSize))
        .lineSpacing(4)
        .foregroundStyle(RecipeTheme.espresso)
        .padding(.leading, leadingPadding)
        .padding(.trailing, trailingPadding)
        .padding(.vertical, verticalPadding)
        .background(MemoPaperBackground())
    }

    private var metadata: some View {
        HStack(spacing: 12) {
            if !snapshot.servingText.isEmpty {
                metadataPill(snapshot.servingText)
            }

            if let cookingTimeText = snapshot.cookingTimeText {
                metadataPill(cookingTimeText)
            }

            if let categoryName = snapshot.categoryName {
                metadataPill(categoryName)
            }
        }
        .font(.system(size: metadataFontSize, weight: .semibold, design: .monospaced))
    }

    private func metadataPill(_ text: String) -> some View {
        Text(text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.68), in: Capsule())
    }

    private func exportSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(RecipeTheme.terracotta)

            content()
        }
    }

    private var shouldShowIngredientGroupTitle: Bool {
        snapshot.ingredientGroups.count > 1
        || snapshot.ingredientGroups.contains { $0.title != "기본 재료" }
    }

    private var hasMetadata: Bool {
        !snapshot.servingText.isEmpty
        || snapshot.cookingTimeText != nil
        || snapshot.categoryName != nil
    }
}

private struct RecipeIndexExportCard: View {
    let snapshot: RecipeExportSnapshot
    @ScaledMetric(relativeTo: .body) private var brandFontSize = 16
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize = 34
    @ScaledMetric(relativeTo: .subheadline) private var categoryFontSize = 16
    @ScaledMetric(relativeTo: .body) private var descriptionFontSize = 18
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 16
    @ScaledMetric(relativeTo: .subheadline) private var groupTitleFontSize = 16
    @ScaledMetric(relativeTo: .caption) private var labelFontSize = 12
    @ScaledMetric(relativeTo: .body) private var valueFontSize = 15
    @ScaledMetric(relativeTo: .title3) private var sectionTitleFontSize = 18
    @ScaledMetric(relativeTo: .caption) private var sourceFooterFontSize = 14
    @ScaledMetric(relativeTo: .body) private var cardPadding = 42

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .firstTextBaseline) {
                Text("RECIPE:UM")
                    .font(.system(size: brandFontSize, weight: .bold, design: .monospaced))
                    .foregroundStyle(RecipeTheme.sage)

                Spacer()

                if let categoryName = snapshot.categoryName {
                    Text(categoryName)
                        .font(.system(size: categoryFontSize, weight: .semibold, design: .monospaced))
                        .foregroundStyle(RecipeTheme.terracotta)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(snapshot.title)
                    .font(.system(size: titleFontSize, weight: .bold, design: .serif))

                if let recipeDescription = snapshot.recipeDescription {
                    Text(recipeDescription)
                        .font(.system(size: descriptionFontSize))
                        .foregroundStyle(.secondary)
                }
            }

            if hasMetadata {
                HStack(spacing: 18) {
                    if !snapshot.servingText.isEmpty {
                        labeledText("분량", snapshot.servingText)
                    }

                    if let cookingTimeText = snapshot.cookingTimeText {
                        labeledText("시간", cookingTimeText)
                    }
                }
            }

            Divider()
                .overlay(RecipeTheme.sage.opacity(0.5))

            twoColumnContent

            if let personalNotes = snapshot.personalNotes {
                Divider()
                    .overlay(RecipeTheme.sage.opacity(0.5))

                VStack(alignment: .leading, spacing: 8) {
                    sectionTitle("내 메모")
                    Text(personalNotes)
                }
            }

            if let source = snapshot.source, source.hasDisplayContent {
                sourceFooter(source)
            }
        }
        .font(.system(size: bodyFontSize))
        .lineSpacing(3)
        .foregroundStyle(RecipeTheme.espresso)
        .padding(cardPadding)
        .background(IndexCardBackground())
    }

    private var twoColumnContent: some View {
        HStack(alignment: .top, spacing: 34) {
            VStack(alignment: .leading, spacing: 12) {
                sectionTitle("재료")

                ForEach(snapshot.ingredientGroups) { group in
                    VStack(alignment: .leading, spacing: 7) {
                        if shouldShowIngredientGroupTitle {
                            Text(group.title)
                                .font(.system(size: groupTitleFontSize, weight: .bold))
                                .foregroundStyle(RecipeTheme.sage)
                        }

                        ForEach(group.ingredients) { ingredient in
                            Text(ingredient.rawText)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if !snapshot.cookingSteps.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    sectionTitle("조리 단계")

                    ForEach(snapshot.cookingSteps) { step in
                        Text("\(step.number). \(step.instruction)")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func labeledText(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: labelFontSize, weight: .bold, design: .monospaced))
                .foregroundStyle(RecipeTheme.sage)
            Text(value)
                .font(.system(size: valueFontSize, weight: .semibold, design: .monospaced))
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: sectionTitleFontSize, weight: .bold, design: .rounded))
            .foregroundStyle(RecipeTheme.terracotta)
    }

    private func sourceFooter(_ source: RecipeExportSnapshot.SourceSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
                .overlay(RecipeTheme.sage.opacity(0.5))

            Text([source.typeName, source.titleOrMemo, source.urlString].compactMap(\.self).joined(separator: " | "))
                .font(.system(size: sourceFooterFontSize, design: .monospaced))
                .foregroundStyle(.secondary)
        }
    }

    private var shouldShowIngredientGroupTitle: Bool {
        snapshot.ingredientGroups.count > 1
        || snapshot.ingredientGroups.contains { $0.title != "기본 재료" }
    }

    private var hasMetadata: Bool {
        !snapshot.servingText.isEmpty || snapshot.cookingTimeText != nil
    }
}

private struct IndexCardBackground: View {
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.96, blue: 0.87)

            RoundedRectangle(cornerRadius: 6)
                .stroke(RecipeTheme.sage.opacity(0.45), lineWidth: 2)
                .padding(14)
        }
    }
}

private struct MemoPaperBackground: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Color(red: 0.99, green: 0.97, blue: 0.91)

            VStack(spacing: 33) {
                ForEach(0..<32, id: \.self) { _ in
                    Rectangle()
                        .fill(Color(red: 0.68, green: 0.76, blue: 0.79).opacity(0.35))
                        .frame(height: 1)
                }
            }
            .padding(.top, 82)

            Rectangle()
                .fill(RecipeTheme.terracotta.opacity(0.6))
                .frame(width: 2)
                .padding(.leading, 48)
        }
    }
}

private struct DashedDivider: View {
    var body: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 6]))
            .foregroundStyle(.secondary.opacity(0.55))
            .frame(height: 1)
    }
}

private struct ReceiptShadowBackground: View {
    var body: some View {
        ZStack {
            RecipeTheme.background
            Color.black.opacity(0.04)
        }
    }
}

#Preview("Receipt") {
    RecipeExportCardView(snapshot: .preview, template: .receipt)
        .frame(width: 360)
}

#Preview("Memo") {
    RecipeExportCardView(snapshot: .preview, template: .memo)
        .frame(width: 360)
}

#Preview("Card") {
    RecipeExportCardView(snapshot: .preview, template: .card)
        .frame(width: 360)
}
