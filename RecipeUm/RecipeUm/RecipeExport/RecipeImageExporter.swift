//
//  RecipeImageExporter.swift
//  RecipeUm
//
//  Created by Codex on 8/27/26.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
struct RecipeImageExporter {
    func exportImage(
        snapshot: RecipeExportSnapshot,
        template: RecipeExportTemplate,
        width: CGFloat,
        dynamicTypeSize: DynamicTypeSize
    ) throws -> ExportedRecipeImage {
        let renderer = ImageRenderer(
            content: RecipeExportCardView(snapshot: snapshot, template: template)
                .frame(width: width)
                .environment(\.dynamicTypeSize, dynamicTypeSize)
        )
        renderer.scale = UIScreen.main.scale

        guard let image = renderer.uiImage else {
            throw RecipeImageExportError.renderingFailed
        }

        return ExportedRecipeImage(image: image)
    }
}

struct ExportedRecipeImage {
    let image: UIImage
}

enum RecipeImageExportError: LocalizedError {
    case renderingFailed

    var errorDescription: String? {
        switch self {
        case .renderingFailed:
            "이미지를 만들 수 없습니다."
        }
    }
}
