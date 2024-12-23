//
//  Annotations.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/21/24.
//

import SwiftUI

struct Annotations {
    var rect: CGRect
    var tag: ImageTag
    var size: CGSize
    
    init(rect: CGRect, tag: ImageTag, size: CGSize) {
        self.rect = rect
        self.tag = tag
        self.size = size
    }
    
    // Convert to normalized coordinates for YOLO format
    func normalize() -> (x: Double, y: Double, width: Double, height: Double) {
        // X and width stay relative to original width
        let normalizedX = rect.midX / size.width
        let normalizedWidth = rect.width / size.width
        
        // Scale y and height from UI height (275) to export height (450)
        let normalizedY = rect.midY / 275.0 * 0.61  // 0.61 is a scaling factor to adjust for 450px height
        let normalizedHeight = rect.height / 450.0   // Height relative to export height
        
        return (normalizedX, normalizedY, normalizedWidth, normalizedHeight)
    }
    
    
    func drawIn(canvasContext: GraphicsContext, canvasSize: CGSize, at: CGPoint) {
        // Create debug visualization of the bounding box
        let path = Path(roundedRect: rect, cornerRadius: 0)
        canvasContext.stroke(
            path,
            with: .color(.red),
            lineWidth: 2
        )
    }
    
    /// Return normalized annotation to be used as .txt in yolo annotation
    ///` class x_center y_center width height` in a normalized xywh format (from 0 to 1)
    ///  Example: `2 0.211429 0.159420 0.045714 0.159420`
    func toText() -> String {
        // Convert to YOLO format: <class> <x_center> <y_center> <width> <height>
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
}
