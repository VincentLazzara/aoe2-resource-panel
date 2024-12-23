//
//  CivType.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/21/24.
//

import SwiftUI

enum CivType {
    case asia
    case greek
    case medi
    case meso
    case nomad
    case orie
    case persian
    case seas
    case slav
    case west
    
    var label: String {
        switch self {
            case .asia: return "asia"
            case .greek: return "greek"
            case .medi: return "medi"
            case .meso: return "meso"
            case .nomad: return "nomad"
            case .orie: return "orie"
            case .persian: return "persian"
            case .seas: return "seas"
            case .slav: return "slav"
            case .west: return "west"
        }
    }
    var resourcePanel: String {
        var panel: String = "resource-panel-\(self.label)"
        return panel
    }
}
