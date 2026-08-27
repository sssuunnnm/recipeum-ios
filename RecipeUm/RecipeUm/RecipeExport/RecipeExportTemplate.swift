//
//  RecipeExportTemplate.swift
//  RecipeUm
//
//  Created by Codex on 8/27/26.
//

import Foundation

enum RecipeExportTemplate: String, CaseIterable, Identifiable {
    case receipt
    case memo
    case card

    var id: Self { self }

    var displayName: String {
        switch self {
        case .receipt:
            "영수증"
        case .memo:
            "메모장"
        case .card:
            "카드"
        }
    }

    var fileNameComponent: String {
        rawValue
    }
}
