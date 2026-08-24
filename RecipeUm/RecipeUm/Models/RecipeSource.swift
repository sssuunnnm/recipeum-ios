//
//  RecipeSource.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class RecipeSource {
    var typeRawValue: String
    var urlString: String?
    var titleOrMemo: String
    var recipe: Recipe?

    var type: RecipeSourceType {
        get {
            RecipeSourceType(rawValue: typeRawValue) ?? .other
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }

    init(
        type: RecipeSourceType = .other,
        urlString: String? = nil,
        titleOrMemo: String = ""
    ) {
        self.typeRawValue = type.rawValue
        self.urlString = urlString
        self.titleOrMemo = titleOrMemo
    }
}

