//
//  ComprehensiveSyntheticDataManager.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/23/24.
//


import SwiftUI
import AppKit

enum QueueItem {
    case villager(progress: Double, opacity: CGFloat)
    case ageUp(age: ImageTag, progress: Double, opacity: CGFloat)
}

// Updated resource coordinates to match actual UI
let resourceOffsets: [Resource: CGPoint] = [
    .wood: CGPoint(x: 120, y: 57),      // Leftmost resource
    .food: CGPoint(x: 320, y: 57),      // Second from left
    .gold: CGPoint(x: 520, y: 57),      // Third from left
    .stone: CGPoint(x: 720, y: 57),     // Fourth from left
    .villagers: CGPoint(x: 920, y: 57)  // Rightmost resource
]
// Add age and villager queue annotations
let queueStartX: CGFloat = 50
let queueY: CGFloat = 156

struct ComprehensiveSyntheticDataManager: View {
    @State private var annotations: [GameAnnotation] = []
    @State private var currentCiv: CivType = .asia
    @State private var currentAge: ImageTag = .age_1
    @State private var background: Int = 1
    
    private let exportSize = CGSize(width: 1750, height: 450)
    private let civTypes: [CivType]
    private let ages: [ImageTag] = [.age_1, .age_2, .age_3, .age_4]
    private let queueAges: [ImageTag] = [.queue_age_2, .queue_age_3, .queue_age_4]
    private let progressSteps: [Double]
    
    init() {
        // Initialize all civ types
        self.civTypes = [
            .asia, .greek, .medi, .meso, .nomad,
            .orie, .persian, .seas, .slav, .west
        ]
        
        // Initialize progress steps
        var steps = [-0.25, 0.0]  // Special cases first
        let nextSteps =  Array(stride(from: 0.2, to: 0.9, by: 0.1))
        steps.append(contentsOf: nextSteps)  // Add remaining fixed steps
        self.progressSteps = steps
    }
    var body: some View {
        VStack {
            AOEMenuView(civType: currentCiv,
                       annotations: $annotations,
                       background: background)
                .frame(width: canvasSize.width, height: canvasSize.height)
        }
        .task {
            await generateAll()
        }
    }
    

    private func generateAll() async {
        for civ in civTypes {
            print("Starting \(civ.label)")
            
            for progress in progressSteps {
                let age = ages.randomElement() ?? .age_1
                await generateBaseState(civ: civ, age: age)
                
                let opacities = progress != 0 ?
                    Array(stride(from: 0.2, to: 0.6, by: 0.1)) : [0.5]
                
                // Randomize background for each main iteration
                await MainActor.run {
                    background = Int.random(in: 1...20)
                }
                
                for opacity in opacities {
                    // Single Villager Queue
                    await generateQueueState(
                        civ: civ,
                        age: age,
                        queueItems: [.villager(progress: progress, opacity: opacity)]
                    )
                    
                    // Generate for each queue age
                    for queueAge in queueAges {
                        // Just age up
                        await generateQueueState(
                            civ: civ,
                            age: age,
                            queueItems: [.ageUp(age: queueAge, progress: progress, opacity: opacity)]
                        )
                        
                        // Batch the two double-queue variations together
                        await withTaskGroup(of: Void.self) { group in
                            // Both queues - villager first
                            group.addTask {
                                await generateQueueState(
                                    civ: civ,
                                    age: age,
                                    queueItems: [
                                        .villager(progress: progress, opacity: opacity),
                                        .ageUp(age: queueAge, progress: progress, opacity: opacity)
                                    ]
                                )
                            }
                            
                            // Both queues - age up first
                            group.addTask {
                                await generateQueueState(
                                    civ: civ,
                                    age: age,
                                    queueItems: [
                                        .ageUp(age: queueAge, progress: progress, opacity: opacity),
                                        .villager(progress: progress, opacity: opacity)
                                    ]
                                )
                            }
                            
                            await group.waitForAll()
                        }
                    }
                }
            }
        }
        print("Generation complete!")
    }

    private func generateQueueState(civ: CivType, age: ImageTag, queueItems: [QueueItem]) async {
        // Update UI state
        await MainActor.run {
            currentCiv = civ
            currentAge = age
            
            var stateAnnotations: [GameAnnotation] = []
            
            // Add resource annotations
            for (resource, position) in resourceOffsets {
                stateAnnotations.append(
                    AnnotationFactory.createResourceAnnotation(
                        resource: resource,
                        canvasSize: canvasSize,
                        coordinate: position
                    )
                )
            }
            
            // Add age annotation
            stateAnnotations.append(
                AnnotationFactory.createAgeAnnotation(
                    at: CGPoint(x: 1212, y: 62),
                    canvasSize: canvasSize,
                    tag: age,
                    civ: civ,
                    clickState: .active
                )
            )
            
            // Add queue items with proper positioning
            for (index, queueItem) in queueItems.enumerated() {
                let xOffset = queueStartX + (index > 0 ? 84 : 0)
                
                switch queueItem {
                case .villager(let progress, let opacity):
                    stateAnnotations.append(
                        AnnotationFactory.createVillagerAnnotation(
                            at: CGPoint(x: xOffset, y: queueY),
                            canvasSize: canvasSize,
                            num: Int.random(in: 1...5),
                            player: Player.random(),
                            progress: progress,
                            progressOpacity: opacity
                        )
                    )
                    
                case .ageUp(let queueAge, let progress, let opacity):
                    stateAnnotations.append(
                        AnnotationFactory.createAgeQueueAnnotation(
                            at: CGPoint(x: xOffset, y: queueY),
                            canvasSize: canvasSize,
                            age: queueAge,
                            progress: progress,
                            progressOpacity: opacity
                        )
                    )
                }
            }
            
            self.annotations = stateAnnotations
        }
        
        // Minimum wait for UI update
        try? await Task.sleep(nanoseconds: 16_666_667) // Approx. 1/60th of a second
        
        // Save the state
        await MainActor.run {
            saveCurrentState(suffix: UUID().uuidString)
        }
    }

    
    private func generateBaseState(civ: CivType, age: ImageTag) async {
        await MainActor.run {
            currentCiv = civ
            currentAge = age
            
            var stateAnnotations: [GameAnnotation] = []
            
            // Add resource annotations
            for (resource, position) in resourceOffsets {
                stateAnnotations.append(
                    AnnotationFactory.createResourceAnnotation(
                        resource: resource,
                        canvasSize: canvasSize,
                        coordinate: position
                    )
                )
            }
            
            // Add age annotation
            stateAnnotations.append(
                AnnotationFactory.createAgeAnnotation(
                    at: CGPoint(x: 1212, y: 62),
                    canvasSize: canvasSize,
                    tag: age,
                    civ: civ,
                    clickState: .active
                )
            )
            
            self.annotations = stateAnnotations
        }
        
        // Wait for UI update
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Save state
        await MainActor.run {
            saveCurrentState(suffix: "base")
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
    
    private func generateQueueState(civ: CivType, age: ImageTag, queueAge: ImageTag, progress: Double, progressOpacity: CGFloat) async {
        await MainActor.run {
            currentCiv = civ
            currentAge = age
            
            var stateAnnotations: [GameAnnotation] = []
            
            // Add resource annotations
            for (resource, position) in resourceOffsets {
                stateAnnotations.append(
                    AnnotationFactory.createResourceAnnotation(
                        resource: resource,
                        canvasSize: canvasSize,
                        coordinate: position
                    )
                )
            }
            
            // Add age annotation
            stateAnnotations.append(
                AnnotationFactory.createAgeAnnotation(
                    at: CGPoint(x: 1212, y: 62),
                    canvasSize: canvasSize,
                    tag: age,
                    civ: civ,
                    clickState: .active
                )
            )
            
            // Add queue age annotation
            stateAnnotations.append(
                AnnotationFactory.createAgeQueueAnnotation(
                    at: CGPoint(x: queueStartX, y: queueY),
                    canvasSize: canvasSize,
                    age: queueAge,
                    progress: progress,
                    progressOpacity: progressOpacity
                )
            )
            
            self.annotations = stateAnnotations
        }
        
        // Wait for UI update
        try? await Task.sleep(nanoseconds: 50_000_000)
        
        // Save state
        await MainActor.run {
            saveCurrentState(suffix: UUID().uuidString)
        }
        
        try? await Task.sleep(nanoseconds: 50_000_000)
    }
}



extension ComprehensiveSyntheticDataManager {
    
    internal func saveCurrentState(suffix: String) {
        let baseName = "aoe2_ui_\(currentCiv.label)_age\(currentAge.rawValue)_\(suffix)_bg\(background)"
        saveTrainingExample(folder: "synthetic-data", baseName: baseName)
    }
    
    
    internal func saveTrainingExample(folder: String, baseName: String) {
        let pngFilename = "\(baseName).png"
        
        guard let window = NSApplication.shared.windows.first,
              let view = window.contentView else {
            print("Could not find window or view")
            return
        }
        
        view.frame = CGRect(origin: .zero, size: exportSize)
        
        guard let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) else { return }
        view.cacheDisplay(in: view.bounds, to: rep)
        guard let cgImage = rep.cgImage else { return }
        
        guard let baseURL = getDownloadsDirectory() else {
            print("Could not find Downloads directory")
            return
        }
        
        let folderURL = baseURL.appendingPathComponent(folder)
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let fileURL = folderURL.appendingPathComponent(pngFilename)
            
            if let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypePNG, 1, nil) {
                let imageProperties = [
                    kCGImagePropertyPixelWidth: exportSize.width,
                    kCGImagePropertyPixelHeight: exportSize.height
                ] as CFDictionary
                
                CGImageDestinationAddImage(destination, cgImage, imageProperties)
                if CGImageDestinationFinalize(destination) {
                    print("✓ Saved: \(currentCiv.label) - Age \(currentAge.rawValue) - BG \(background)")
                    if saveAnnotations(to: folder, filename: baseName) {
                        print("  └─ Annotations saved")
                    }
                }
            }
        } catch {
            print("Failed to save PNG: \(error)")
        }
    }
    
    internal func saveAnnotations(to folder: String, filename: String) -> Bool {
        guard let baseURL = getDownloadsDirectory() else {
            print("Could not find Downloads directory")
            return false
        }
        
        let folderURL = baseURL.appendingPathComponent(folder)
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            print("Failed to create directory: \(error)")
            return false
        }
        
        let annotationText = annotations.map { $0.toText() }.joined(separator: "\n")
        let annotationURL = folderURL.appendingPathComponent(filename).appendingPathExtension("txt")
        
        do {
            try annotationText.write(to: annotationURL, atomically: true, encoding: .utf8)
            return true
        } catch {
            print("Failed to save annotations: \(error)")
            return false
        }
    }
    
    internal func getDownloadsDirectory() -> URL? {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
    }
}
