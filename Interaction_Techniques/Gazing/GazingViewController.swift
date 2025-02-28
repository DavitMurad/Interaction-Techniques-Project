//
//  GazingViewController.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 22.02.25.
//

import UIKit
import ARKit
import AudioToolbox


class GazingViewController: UIViewController, ARSessionDelegate {
    @IBOutlet weak var centralButton: UIButton!
    @IBOutlet weak var blinkCount: UILabel!
    @IBOutlet weak var pressedCount: UILabel!
    
    var sceneView: ARSCNView!
    var floatingCursor: UIView!

    var blinkCountValue: Int = 0
    var pressedCountValue: Int = 0
    
    // Throttle blink detection
    var lastBlinkTime = Date().addingTimeInterval(-1)
    let blinkCooldown: TimeInterval = 0.5 // 1 second cooldown
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralButton.layer.cornerRadius = 8
        setupAR()
        setupCursor()
        findButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    func setupAR() {
        let previewSize: CGFloat = 150
        let margin: CGFloat = 20

        sceneView = ARSCNView(frame: CGRect(
            x: margin,
            y: view.bounds.height - previewSize - margin,
            width: previewSize,
            height: previewSize
        ))
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.scene = SCNScene()
        sceneView.isHidden = true
        view.addSubview(sceneView)
    }

    func setupCursor() {
        floatingCursor = UIView(frame: CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 40, height: 40))
        floatingCursor.backgroundColor = .green
        floatingCursor.layer.cornerRadius = 20
        view.addSubview(floatingCursor)
    }

    func findButton() {
        if let existingButton = self.view.viewWithTag(100) as? UIButton {
            centralButton = existingButton
        } else {
            print("Button with tag 100 not found!")
        }
        startFaceTracking()
    }

    func startFaceTracking() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face Tracking not supported")
            return
        }
        sceneView.session.run(ARFaceTrackingConfiguration())
    }

    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.first as? ARFaceAnchor else { return }

        DispatchQueue.main.async {
            let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft]?.floatValue ?? 0.0
            let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight]?.floatValue ?? 0.0

            let isBlinking = leftEyeBlink > 0.6 && rightEyeBlink > 0.6

            if !isBlinking {
                let leftGaze = faceAnchor.leftEyeTransform.columns.2
                let rightGaze = faceAnchor.rightEyeTransform.columns.2

                let averageGazeX = (leftGaze.x + rightGaze.x) / 2
                let averageGazeY = (leftGaze.y + rightGaze.y) / 2

                self.updateCursorPosition(eyeLookX: averageGazeX, eyeLookY: averageGazeY)
            } else {
                // 👇 Ensure cursor stays still during blink by not updating its position
                print("Blinking - Cursor position locked")
            }

            self.detectBlink(isBlinking: isBlinking)
        }
    }


    func updateCursorPosition(eyeLookX: Float, eyeLookY: Float) {
        let sensitivity: CGFloat = 1000
        let newX = view.bounds.midX - CGFloat(eyeLookX) * sensitivity
        let newY = view.bounds.midY - CGFloat(eyeLookY) * sensitivity

        UIView.animate(withDuration: 0.1) {
            self.floatingCursor.center = CGPoint(x: newX, y: newY)
        }
    }

    func detectBlink(isBlinking: Bool) {
        if isBlinking && Date().timeIntervalSince(lastBlinkTime) > blinkCooldown {
            lastBlinkTime = Date()
            
            print("👁️ Blink Detected - Confirming Selection!")
            blinkCountValue += 1
            blinkCount.text = "\(blinkCountValue)"

            confirmSelection()
        }
    }

    func confirmSelection() {
        let cursorFrame = floatingCursor.frame
        
        // Add offset around button frame
        let buttonInteractiveFrame = centralButton.frame.insetBy(dx: -20, dy: -20)
        
        if cursorFrame.intersects(buttonInteractiveFrame) {
            print("🎯 Button Selected!")
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()

            centralButton.sendActions(for: .touchUpInside)

            pressedCountValue += 1
            pressedCount.text = "\(pressedCountValue)"
        }
    }

}
