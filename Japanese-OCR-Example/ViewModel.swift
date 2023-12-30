//
//  ViewModel.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/30.
//

import Foundation
import CoreImage
import Observation
import UIKit
import Vision

@Observable
class ViewModel: NSObject {
    
    var buffImage: UIImage? = nil
    var recognizedText: String = ""
    
    let cameraManager = CameraManager()
    
    // カメラ映像を変換したCGImage出力
    var frame: CGImage?
    
    override init() {
        super.init()
    }
    
    // テキスト認識
    func recognizeText(sampleBuffer: CMSampleBuffer) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let maximumCandidates = 1
            self.recognizedText = ""
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.recognizedText += candidate.string
            }
            print(self.recognizedText)
        }
        request.recognitionLanguages = ["ja-JP"]
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        try? handler.perform([request])
    }
    
    func start() {
        cameraManager.start { sampleBuffer in
            self.recognizeText(sampleBuffer: sampleBuffer)
            if let convertImage = self.createUIImageFromSampleBuffer(sampleBuffer) {
                DispatchQueue.main.async {
                    self.buffImage = convertImage
                }
            }
        }
    }
    
    func stop() {
        cameraManager.stop()
    }
    
    // CMSampleBufferからUIImageを生成
    func createUIImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
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
