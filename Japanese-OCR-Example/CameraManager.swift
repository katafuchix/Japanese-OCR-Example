//
//  CameraManager.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/30.
//

import Foundation
import AVFoundation
import Observation

// カメラ管理クラス
//@Observable
class CameraManager: NSObject {
    let captureSession = AVCaptureSession()
    var handler: ((CMSampleBuffer) -> Void)?
    
    // バッファ出力用
    var currentBuffer: CMSampleBuffer?
    
    override init() {
        super.init()
        setup()
    }

    func setup() {
        captureSession.beginConfiguration()
        let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let camera = device else {
            print("カメラ利用不可")
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: camera), captureSession.canAddInput(deviceInput) else {
            print("カメラ利用不可")
            return
        }
        captureSession.addInput(deviceInput)

        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "mydispatchqueue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        guard captureSession.canAddOutput(videoDataOutput) else { return }
        captureSession.addOutput(videoDataOutput)

        // アウトプットの画像を縦向きに変更 90度回転
        for connection in videoDataOutput.connections {
            if connection.isVideoRotationAngleSupported(90) {
                connection.videoRotationAngle = 90
            }
        }
        captureSession.commitConfiguration()
    }

    // 開始 observation では上手く取れないのでバッファをハンドラで受ける設定とする
    func start(_ handler: @escaping (CMSampleBuffer) -> Void)  {
        if !captureSession.isRunning {
            self.handler = handler
            captureSession.startRunning()
        }
    }
    
    // 停止
    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    // カメラ出力後の処理
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // ハンドラに流す
        self.handler?(sampleBuffer)
    }
}
