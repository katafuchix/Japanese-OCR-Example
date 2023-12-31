//
//  OCRManager.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/31.
//

import Foundation
import AVFoundation
import Observation
import UIKit
import Vision

@Observable
class OCRManager: NSObject {
    private let session = AVCaptureSession()
    
    var previewImage: UIImage?
    var recognizedText: String = ""

    override init() {
        super.init()
        self.setupCameraInput()
        self.setupVideoOutput()
    }
    
    func startCaptureSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    func stopCaptureSession() {
        self.session.stopRunning()
    }
    
    // カメラ入力準備
    private func setupCameraInput() {
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        //session.sessionPreset = .photo
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }
    
    // カメラ出力準備
    private func setupVideoOutput() {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        // アウトプットの画像を縦向きに変更 90度回転 セッション追加の後に行う
        for connection in videoOutput.connections {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
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
    
}

extension OCRManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // サンプルバッファから画像データを取得
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
    
        // テキスト認識
        self.recognizeText(sampleBuffer: sampleBuffer)
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        //let correctedImage = ciImage.oriented(.right) // 回転と方向の補正
        
        let context = CIContext()
        // CIImageをCGImageに変換する
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        // CGImageからUIImageを作成
        let uiImage = UIImage(cgImage: cgImage)
        
        // 画像の更新をメインスレッドで行う
        DispatchQueue.main.async { [weak self] in
            // プロパティに画像を設定
            self?.previewImage = uiImage
        }
    }
}
