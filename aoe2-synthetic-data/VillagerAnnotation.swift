//
//  VillagerAnnotation.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/10/24.
//

import SwiftUI


// Villager annotation with progress
class VillagerAnnotation: GameAnnotation {
    let player: Player
    let num: Int
    let progress: Double // 0.0 to 1.0
    let progressOpacity: CGFloat
    init(rect: CGRect, tag: ImageTag, size: CGSize, player: Player, num: Int, progress: Double, progressOpacity: CGFloat, overlay: String = "icon_overlay_normal") {
        self.player = player
        self.num = num
        self.progress = progress
        self.progressOpacity = progressOpacity
        self.overlay = overlay
        super.init(rect: rect, tag: tag, size: size)
    }
    
    var overlay: String
    var imageName: String {
        let num = Bool.random() ? "1" : "2"
        var image = "villager-\(num)"
        if tag == .alert_housed {
            image += "-disabled"
        }
        return image
    }
    
    override
    func drawIn(context: GraphicsContext, canvasSize: CGSize) {
        // First, draw the textured base image
        let texturedImage = context.resolve(Image(imageName + "-textured"))
        
        // Create a new layer for blending
        context.drawLayer { subcontext in
            // Draw the base texture first
            subcontext.draw(texturedImage, in: rect)
            
           //Draw num
            
            // Set up multiply blend mode for the color layer
            subcontext.blendMode = .multiply
            
            // Draw the color layer with player color
            let colorImage = context.resolve(Image((tag == .alert_housed) ? "player_black" : player.rawValue))
            subcontext.draw(colorImage, in: rect)
            
            // Optional: Add a soft light layer for better detail preservation
            subcontext.blendMode = .softLight
            subcontext.opacity = 0.3
            subcontext.draw(colorImage, in: rect)
        }
        context.draw(Image(imageName), in: rect)
        
        // Draw the number with outline and inner shadow
        var numString = AttributedString(String(num))
        numString.font = .init(name: "LibreBaskerville-Bold", size: rect.height * 0.45)
        numString.foregroundColor = .white
        
        // Center position calculation - adjusted to match original
        let centerX = rect.minX + 14// Center horizontally
        let centerY = rect.minY + 20 // Slightly above center vertically
        
        // Draw black outline by rendering text multiple times offset
        let outlineOffsets: [(CGFloat, CGFloat)] = [
            (-1, -1), (-1, 0), (-1, 1),
            (0, -1),           (0, 1),
            (1, -1),  (1, 0),  (1, 1)
        ]
        
        // First draw the outline
        var outlineString = numString
        outlineString.foregroundColor = .black
        let textResolver = context.resolve(Text(outlineString))
        
        for (dx, dy) in outlineOffsets {
                context.draw(textResolver, at: CGPoint(
                    x: centerX + dx,
                    y: centerY + dy
                ))
            }
        
        // Inner shadow
          var shadowString = numString
          shadowString.foregroundColor = .black.opacity(0.3)
          let shadowResolver = context.resolve(Text(shadowString))
          context.draw(shadowResolver, at: CGPoint(
              x: centerX + 1,
              y: centerY + 1
          ))
          
          // Main white text
          let mainTextResolver = context.resolve(Text(numString))
          context.draw(mainTextResolver, at: CGPoint(
              x: centerX,
              y: centerY
          ))
        // Draw any additional overlays if needed
        if tag != .alert_housed {
            context.draw(Image(overlay), in: rect)
            
            if progress == -0.25 {
                drawQueuedOverlay(context: context, rect: rect)
            } else {
                drawProgessBar(progress: progressOpacity, progressOpacity: 0.6, context: context, rect: rect)
            }
        }
    }
}




func drawProgessBar(progress: Double,progressOpacity: CGFloat, context: GraphicsContext, rect: CGRect) {
    if progress > 0.01 {
        let progressWidth = CGFloat(progress * Double(rect.width))
        let progressRect = CGRect(x: rect.minX, y: rect.minY, width: progressWidth, height: rect.height)
     
        let path = Path(progressRect)
        context.fill(path, with: .color(.green.opacity(progressOpacity)))
    }
    
}


func drawQueuedOverlay(context: GraphicsContext, rect: CGRect) {
    let path = Path(rect)
    let color: Color = Color(hex: "ca9723")
    let opacity: Double = 0.6
    context.fill(path, with: .color(color.opacity(opacity)))
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
