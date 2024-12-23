//
//  Age-Queue-Annotation.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/21/24.
//

import SwiftUI


class AgeQueueAnnotation: GameAnnotation {
    let progress: Double // 0.0 to 1.0
    let progressOpacity: CGFloat
    var overlay: String
    var imageName: String {
        var base: String = "age-"
        switch tag {
            case .queue_age_2: base += "2"
            case .queue_age_3: base += "3"
            case .queue_age_4: base += "4"
            default: return base
        }
        base += "-up"
        return base
    }
    
    init(rect: CGRect, tag: ImageTag, size: CGSize, progress: Double, progressOpacity: CGFloat, overlay: String = "icon_overlay_normal") {
        self.progress = progress
        self.progressOpacity = progressOpacity
        self.overlay = overlay
        
        super.init(rect: rect, tag: tag, size: size)
    }
    
    override
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        let image = context.resolve(Image(imageName))
        context.draw(image, in: rect)
        
        
        // Draw icon overlay
        context.draw(Image(overlay), in: rect)
        
        if progress == -0.25 {
            drawQueuedOverlay(context: context, rect: rect)
        } else {
            drawProgessBar(progress: progress, progressOpacity: progressOpacity, context: context, rect: rect)
        }
        
    }
}
