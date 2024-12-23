//
//  AgeAnnotation.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/22/24.
//

import SwiftUI


enum AgeClickState: String {
    case active = "active"
    case normal = "normal"
    case hover = "hover"
}

class AgeAnnotation: GameAnnotation {
    let civ: CivType
    let clickState: AgeClickState
    
    init(size: CGSize, rect: CGRect, tag: ImageTag, civ: CivType, clickState: AgeClickState) {
        self.civ = civ
        self.clickState = clickState
        super.init(rect: rect, tag: tag, size: size)
    }
    private var imageName: String {
        ///`shield_castle_age_afri_normal`
        var name = "shield_"
        switch tag {
            case .age_1: name += "dark_"
            case .age_2: name += "feudal_"
            case .age_3: name += "castle_"
            case .age_4: name += "imperial_"
            default: break
        }
        name += "age_\(civ.label)_"
        name += clickState.rawValue
        return name
    }
    
    override
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        context.draw(Image(imageName), in: rect)
    }
    
    /*
     override func normalize() -> (x: Double, y: Double, width: Double, height: Double) {
         // X and width stay relative to original width
         let normalizedX = rect.midX / size.width
         let normalizedWidth = rect.width / size.width
         
         // Scale y and height from UI height (275) to export height (450)
         let normalizedY = (rect.midY) / 275.0 * 0.61  // 0.61 is a scaling factor to adjust for 450px height
         let normalizedHeight = (rect.height) / 450.0   // Height relative to export height
         
         return (normalizedX, normalizedY, normalizedWidth, normalizedHeight)
     }
     */
}


