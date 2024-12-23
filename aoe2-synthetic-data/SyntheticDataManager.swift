//
//  SyntheticDataManager.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/21/24.
//


import SwiftUI
import AppKit

// Coordinator view that manages AOEMenuView and handles saving
struct SyntheticDataManager: View {
    @State private var annotations: [GameAnnotation] = []
    private let exportSize = CGSize(width: 1750, height: 450)
    var body: some View {
        AOEMenuView(civType: .asia, annotations: $annotations, background: 1)
            .frame(width: canvasSize.width, height: canvasSize.height)

            .onAppear {
                
            }
    }
    
    // Get the actual Downloads directory path
    private func getDownloadsDirectory() -> URL? {
        let paths = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        guard let downloadPath = paths.first else { return nil }
        return URL(fileURLWithPath: downloadPath)
    }
    
    // Function to save YOLO annotations to a text file
    private func saveAnnotations(to folder: String, filename: String) -> Bool {
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
            print("Successfully saved annotations to: \(annotationURL.path)")
            return true
        } catch {
            print("Failed to save annotations: \(error)")
            return false
        }
    }

    private func saveTrainingExample(folder: String, baseName: String) {
        let pngFilename = "\(baseName).png"
        
        guard let window = NSApplication.shared.windows.first,
              let view = window.contentView else {
            print("Could not find window or view")
            return
        }
        
        // Force the view to use our exact dimensions
        view.frame = CGRect(origin: .zero, size: exportSize)
        
        // Create CGImage from view with exact dimensions
        let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds)!
        view.cacheDisplay(in: view.bounds, to: rep)
        let cgImage = rep.cgImage!
        
        // Verify export dimensions
        print("Exporting image with size: \(cgImage.width) x \(cgImage.height)")
        
        // Save PNG with exact dimensions
        guard let baseURL = getDownloadsDirectory() else {
            print("Could not find Downloads directory")
            return
        }
        
        let folderURL = baseURL.appendingPathComponent(folder)
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            let fileURL = folderURL.appendingPathComponent(pngFilename)
            
            if let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypePNG, 1, nil) {
                // Add image size requirements to ensure exact dimensions
                let imageProperties = [
                    kCGImagePropertyPixelWidth: exportSize.width,
                    kCGImagePropertyPixelHeight: exportSize.height
                ] as CFDictionary
                
                CGImageDestinationAddImage(destination, cgImage, imageProperties)
                if CGImageDestinationFinalize(destination) {
                    print("Successfully saved PNG at \(exportSize.width) x \(exportSize.height)")
                    if saveAnnotations(to: folder, filename: baseName) {
                        print("Successfully saved training example: \(baseName)")
                    }
                }
            }
        } catch {
            print("Failed to save PNG: \(error)")
        }
    }
}

// Extension to capture NSView as CGImage
extension NSView {
    func bitmapImage() -> CGImage {
        let rep = bitmapImageRepForCachingDisplay(in: bounds)!
        cacheDisplay(in: bounds, to: rep)
        return rep.cgImage!
    }
}
