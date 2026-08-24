//
//  Item.swift
//  RecipeUm
//
//  Created by 이선민 on 8/24/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
