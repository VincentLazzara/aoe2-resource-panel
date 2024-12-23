//
//  Resource.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/21/24.
//

import SwiftUI

enum Resource: String, CaseIterable {
    case wood = "resource_wood"
    case stone = "resource_stone"
    case food = "resource_food"
    case gold = "resource_gold"
    case villagers = "pop"
    
    var coordinate: CGPoint {
        switch self {
            case .wood: return CGPoint(x: 57, y: 57)
            case .stone: return CGPoint(x: 657, y: 57)
            case .food: return CGPoint(x: 257, y: 57)
            case .gold: return CGPoint(x: 457, y: 57)
            case .villagers: return CGPoint(x: 856, y: 57)
        }
    }
    
    var tag: ImageTag {
        switch self {
            case .food: return .icon_food
            case .gold: return .icon_gold
            case .stone: return .icon_stone
            case .wood: return .icon_wood
            case .villagers: return .icon_vil
        }
    }
}
