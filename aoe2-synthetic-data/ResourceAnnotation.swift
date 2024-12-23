//
//  ResourceAnnotation.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/10/24.
//

import SwiftUI

// Resource annotation with text overlay
class ResourceAnnotation: GameAnnotation {
    let resource: Resource  // Store the resource
    let amount: Int
    let workerCount: Int
    
    init(rect: CGRect, tag: ImageTag, size: CGSize, resource: Resource, amount: Int, workerCount: Int) {
        self.resource = resource
        self.amount = amount
        self.workerCount = workerCount
        super.init(rect: rect, tag: tag, size: size)
    }
    
    override
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        // Draw the resource icon
        let image = Image(resource.rawValue)
        let resolvedImage = context.resolve(image)
        context.draw(resolvedImage, in: rect)
        
        var numString = AttributedString(String(amount))
        numString.font = .init(name: "BorgiaPro-Bold", size: rect.height * 0.36)
        numString.foregroundColor = .white
        // Draw amount text
        let amountText = Text(numString)
           // .font(.system(size: 28, weight: .bold))
          //  .foregroundColor(.white)
        
        context.draw(amountText, at: CGPoint(
            x: rect.minX + 90,
            y: rect.minY + 48
        ), anchor: .leading)
        
        // Draw worker count
        
        var workerString = AttributedString(String(workerCount))
        workerString.font = .init(name: "BorgiaPro-Bold", size: rect.height * 0.42)
        workerString.foregroundColor = Color(hex: "#ffcf00")
        
        let workerText = Text(workerString)
           // .font(.system(size: 32, weight: .bold))
            //.foregroundColor(.yellow)
        
        context.draw(workerText, at:
                        CGPoint(x: rect.minX + 78,
                               y: rect.minY + 70), anchor: .trailing
        )
        
        var newRectHeight = rect.height * 0.6
        var newRect = CGRect(x: rect.minX, y: rect.minY, width: rect.width-4, height: newRectHeight)
        self.rect = newRect
//        context.draw(workerText, at: CGPoint(
//            x: rect.minX + 16,
//            y: rect.minY + 55
//        ), anchor: .trailing)
    }
    

    
}

// Extension to handle resource annotations
extension Resource {
    func createAnnotation(canvasSize: CGSize) -> Annotations {
        // Use a smaller icon size for the annotation to only include the icon portion
        let iconSize = CGSize(width: 64, height: 64)  // Reduced from 84x84 to only include icon
        let rect = CGRect(
            x: coordinate.x - iconSize.width/2,
            y: coordinate.y - iconSize.height/2,
            width: iconSize.width,
            height: iconSize.height
        )
        
        let tag: ImageTag
        switch self {
        case .wood:
            tag = .icon_wood
        case .food:
            tag = .icon_food
        case .gold:
            tag = .icon_gold
        case .stone:
            tag = .icon_stone
        case .villagers:
            tag = .icon_vil
        }
        
        return Annotations(rect: rect, tag: tag, size: canvasSize)
    }
}
