//
//  ContentView.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/30.
//

import SwiftUI
import VideoToolbox

struct ContentView: View {
    let ocrManager = OCRManager()
    
    var body: some View {
        ZStack {
            if let image = ocrManager.previewImage {
            Image(uiImage: image)
                    .resizable()
                    .padding(.leading, 1)
            }
        
            Text(ocrManager.recognizedText)
                .fontWeight(.bold)
                .font(.largeTitle)
            
            ControlView(
                startHandler: { ocrManager.startCaptureSession() },
                stopHandler: { ocrManager.stopCaptureSession() }
            )
        }.edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
