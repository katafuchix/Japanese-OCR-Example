//
//  ContentView.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/30.
//

import SwiftUI
import VideoToolbox

struct ContentView: View {
    let viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            if let image = viewModel.buffImage {
            Image(uiImage: image)
                    .resizable()
                    .padding(.leading, 1)
            }
        
            Text(viewModel.recognizedText)
                .fontWeight(.bold)
                .font(.largeTitle)
            
            ControlView(
                startHandler: { viewModel.start() }, 
                stopHandler: { viewModel.stop() }
            )
        }.edgesIgnoringSafeArea(.all)
        
    }
    
    
    func UIImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let context = CIContext()
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image)
            }
        }
        return nil
    }
}

extension CGImage {
    // 映像バッファからCGImageを生成
    static func create(from cvPixelBuffer: CVPixelBuffer?) -> CGImage? {
        guard let pixelBuffer = cvPixelBuffer else {
            return nil
        }
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        return image
    }
}



#Preview {
    ContentView()
}
