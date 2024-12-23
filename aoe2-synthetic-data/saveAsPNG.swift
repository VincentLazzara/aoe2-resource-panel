//
//  saveAsPNG.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/8/24.
//

import SwiftUI

extension View {
    /// Saves the current View as a PNG file into the specified system directory and folder.
    /// - Parameters:
    ///   - folder: The name of the subfolder to place the file in. Will be created if it doesn't exist.
    ///   - directory: The `FileManager.SearchPathDirectory` to use, such as `.downloadsDirectory` or `.documentDirectory`.
    ///   - filename: The name of the PNG file to create (e.g., "snapshot.png").
    ///   - completion: A closure called after attempting to save. If successful, `error` is `nil`, otherwise it contains the error.
    func saveAsPNG(folder: String,
                   in directory: FileManager.SearchPathDirectory,
                   filename: String,
                   completion: @escaping (Error?) -> Void) {
        
        // Create an NSHostingView to render the SwiftUI view
        let hostingView = NSHostingView(rootView: self)
        
        // Force layout to ensure we get the correct size
        hostingView.layoutSubtreeIfNeeded()
        
        // Determine the natural size of the view after layout
        let size = hostingView.fittingSize
        hostingView.setFrameSize(size)
        
        // Attempt to create a bitmap representation
        guard let bitmapRep = hostingView.bitmapImageRepForCachingDisplay(in: hostingView.bounds) else {
            completion(NSError(domain: "ViewSnapshotError",
                               code: 1,
                               userInfo: [NSLocalizedDescriptionKey: "Failed to create bitmap representation."]))
            return
        }
        
        // Render the view into the bitmap representation
        hostingView.cacheDisplay(in: hostingView.bounds, to: bitmapRep)
        
        // Convert to PNG data
        guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
            completion(NSError(domain: "ViewSnapshotError",
                               code: 2,
                               userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG data."]))
            return
        }
        
        // Find the desired directory (e.g. Downloads, Documents)
        guard let baseURL = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            completion(NSError(domain: "ViewSnapshotError",
                               code: 3,
                               userInfo: [NSLocalizedDescriptionKey: "Could not find the specified directory."]))
            return
        }
        
        // Create the folder inside the directory if needed
        let folderURL = baseURL.appendingPathComponent(folder)
        
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            completion(NSError(domain: "ViewSnapshotError",
                               code: 4,
                               userInfo: [NSLocalizedDescriptionKey: "Failed to create folder: \(error.localizedDescription)"]))
            return
        }
        
        // Construct the full file URL
        let fileURL = folderURL.appendingPathComponent(filename)
        
        // Write the PNG data to the file
        do {
            try pngData.write(to: fileURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
