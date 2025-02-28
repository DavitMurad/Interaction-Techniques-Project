//
//  GestureViewController.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 27.02.25.
//
import UIKit
import Vision
import AVFoundation



class GestureViewController: UIViewController {
    
    private var captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var handPoseRequest = VNDetectHumanHandPoseRequest()
    private var previousPoint: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            fatalError("No front camera found")
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            fatalError("Cannot create video input")
        }
        
        captureSession.addInput(input)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)
        captureSession.startRunning()
    }
    
    private func processHandGesture(_ observations: [VNHumanHandPoseObservation]) {
        guard let observation = observations.first else { return }
        
        do {
            let thumbTip = try observation.recognizedPoint(.middleTip)
            let indexTip = try observation.recognizedPoint(.middleTip)
            
            let thumbPosition = CGPoint(x: thumbTip.location.x, y: 1 - thumbTip.location.y)
            let indexPosition = CGPoint(x: indexTip.location.x, y: 1 - indexTip.location.y)
            
            let handPosition = CGPoint(
                x: (thumbPosition.x + indexPosition.x) / 2,
                y: (thumbPosition.y + indexPosition.y) / 2
            )
            
            detectSwipeGesture(currentPoint: handPosition)
        } catch {
            print("Error detecting hand landmarks: \(error)")
        }
    }
    
    private func detectSwipeGesture(currentPoint: CGPoint) {
        guard let previous = previousPoint else {
            previousPoint = currentPoint
            return
        }
        
        let deltaX = currentPoint.x - previous.x
        let movementThreshold: CGFloat = 0.15  // Adjust to make less sensitive
        
        if abs(deltaX) > movementThreshold {
            if deltaX > 0 {
                print("👉 Swipe Right")
            } else {
                print("👈 Swipe Left")
            }
            previousPoint = nil  // Reset so it doesn’t trigger repeatedly
        } else {
            previousPoint = currentPoint
        }
    }
}

extension GestureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        
        do {
            try requestHandler.perform([handPoseRequest])
            if let results = handPoseRequest.results {
                processHandGesture(results)
            }
        } catch {
            print("Failed to process hand gesture: \(error)")
        }
    }
}
