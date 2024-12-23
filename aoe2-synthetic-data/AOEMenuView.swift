//
//  AOEMenuView.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/9/24.
//

import SwiftUI
import AppKit
let canvasSize = CGSize(width: 1750, height: 450)
struct AOEMenuView: View {
    var civType: CivType
    @Binding var annotations: [GameAnnotation]
    @State var showAnnotations: Bool = true  // Add debug visualization toggle
    
    var background: Int

//    private func createAnnotations() -> [GameAnnotation] {
//        var annotations: [GameAnnotation] = []
//        
//        // Updated resource coordinates to match actual UI
//        let resourceOffsets: [Resource: CGPoint] = [
//            .wood: CGPoint(x: 120, y: 57),      // Leftmost resource
//            .food: CGPoint(x: 320, y: 57),      // Second from left
//            .gold: CGPoint(x: 520, y: 57),      // Third from left
//            .stone: CGPoint(x: 720, y: 57),     // Fourth from left
//            .villagers: CGPoint(x: 920, y: 57)  // Rightmost resource
//        ]
//        
//        // Add resource annotations with updated positions
//        for (resource, position) in resourceOffsets {
//            annotations.append(
//                AnnotationFactory.createResourceAnnotation(
//                    resource: resource,
//                    canvasSize: canvasSize,
//                    coordinate: position
//                )
//            )
//        }
//        
//        // Add age and villager queue annotations
//        let queueStartX: CGFloat = 50
//        let queueY: CGFloat = 156
//        
//        // Age upgrade queue
//        annotations.append(
//            AnnotationFactory.createAgeQueueAnnotation(
//                at: CGPoint(x: queueStartX, y: queueY),
//                canvasSize: canvasSize,
//                age: .queue_age_2,
//                progress: -0.25
//            )
//        )
//        
//        // Villager queue
//        annotations.append(
//            AnnotationFactory.createVillagerAnnotation(
//                at: CGPoint(x: queueStartX + 84, y: queueY),
//                canvasSize: canvasSize,
//                num: 1,
//                progress: -0.25
//            )
//        )
//        
//        annotations.append(AnnotationFactory.createAgeAnnotation(at: CGPoint(x: 1212, y: 62), canvasSize: canvasSize, tag: .age_4, civ: civType, clickState: .active))
//        return annotations
//    }
    
    var body: some View {
        ZStack {
            Image("\(background)")
            VStack(spacing: 0) {
                mainView
//                    .onAppear {
//                        self.annotations = createAnnotations()
//                    }
                Spacer()
                
                debugView
            }
        }
    }
    
    private var mainView: some View {
        panel
    }
    
    private var panel: some View {
        Canvas { context, size in
            // Draw resource panel background
            let resourcePanel = Image("\(civType.resourcePanel)")
            context.draw(resourcePanel, at: CGPoint(x: size.width / 2, y: size.height / 2))
            
            // Draw annotations and debug visualization
            for annotation in annotations {
                annotation.drawIn(context: context, canvasSize: size)
            }
        }
        .frame(width: canvasSize.width, height: 276)
    }
    
    private var debugView: some View {
        VStack(alignment: .leading) {
//            Text("YOLO Annotations:")
//                .font(.headline)
            ForEach(Array(annotations.enumerated()), id: \.offset) { _, annotation in
                EmptyView()
            }
            .foregroundStyle(Color.white)
        }

    }
}
