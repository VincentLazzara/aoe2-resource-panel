//
//  PNGSavingView.swift
//  aoe2-synthetic-data
//
//  Created by Vincent Lazzara on 12/7/24.
//

import SwiftUI


struct TestSaveView: View {
    var body: some View {
        VStack {
            Text("Hello, PNG!")
                .font(.largeTitle)
                .padding()
            Text("This view will be saved as a PNG once.")
        }
        .frame(width: 200, height: 200)
    }
}
struct PNGSavingView: View {
    @State private var hasSaved = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TestSaveView()
//            .onAppear {
//                let view = TestSaveView()
//                view.saveAsPNG(folder: "MyImages", in: FileManager.SearchPathDirectory.downloadsDirectory, filename: "snapshot.png") { error in
//                    if let error = error {
//                        print("Failed to save PNG:", error)
//                    } else {
//                        print("PNG saved successfully!")
//                    }
//                }
//
//            }
        }
    }
    

}

struct PNGSavingView_Previews: PreviewProvider {
    static var previews: some View {
        PNGSavingView()
    }
}
