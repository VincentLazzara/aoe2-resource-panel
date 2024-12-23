//
//  GameAnnotation.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/10/24.
//

import SwiftUI

class GameAnnotation {
    var rect: CGRect
    var tag: ImageTag
    var size: CGSize
    
    init(rect: CGRect, tag: ImageTag, size: CGSize) {
        self.rect = rect
        self.tag = tag
        self.size = size
    }
    
    // Core functions
    func normalize() -> (x: Double, y: Double, width: Double, height: Double) {
        // X and width stay relative to original width
        let normalizedX = rect.midX / size.width
        let normalizedWidth = rect.width / size.width
        
        // Scale y and height from UI height (275) to export height (450)
        let normalizedY = rect.midY / 275.0 * 0.61  // 0.61 is a scaling factor to adjust for 450px height
        let normalizedHeight = rect.height / 450.0   // Height relative to export height
        
        return (normalizedX, normalizedY, normalizedWidth, normalizedHeight)
    }
    
    func toText() -> String {
        let normalized = normalize()
        return String(
            format: "%d %.6f %.6f %.6f %.6f",
            tag.rawValue,
            normalized.x,
            normalized.y,
            normalized.width,
            normalized.height
        )
    }
    
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        
    }
}

// Default implementation for common annotation behavior

// Base struct for common annotation properties
class BaseAnnotation: GameAnnotation {
    override
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        // Default implementation just draws the debug box
        #if DEBUG
        let path = Path(roundedRect: rect, cornerRadius: 0)
        context.stroke(path, with: .color(.red), lineWidth: 2)
        #endif
    }
}
