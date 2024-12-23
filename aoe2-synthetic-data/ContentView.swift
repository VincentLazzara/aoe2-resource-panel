//
//  ContentView.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/7/24.
//

import SwiftUI

struct ContentView: View {
    init() {
        // The text we want to write
        let textToWrite = "Hello World"
        
        //if let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

        // Attempting to find the user's Desktop directory
        if let desktopURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first {
            // Constructing the file path (e.g. ~/Desktop/hello_world.txt)
            let fileURL = desktopURL.appendingPathComponent("hello_world.txt")
            
            do {
                // Write the text into the file
                try textToWrite.write(to: fileURL, atomically: true, encoding: .utf8)
                print("File saved successfully at: \(fileURL.path)")
            } catch {
                // Handle any errors
                print("Failed to save file: \(error.localizedDescription)")
            }
        } else {
            print("Could not find the Desktop directory.")
        }
    }

    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
