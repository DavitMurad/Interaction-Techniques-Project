//
//  Cards.swift
//  sensorHCI
//
//  Created by Davit Muradyan on 15.02.25.
//

import SwiftUI
import CoreMotion


struct Cards: View {
    @State private var isHoldingCard = false // Track if the user is pressing
    @State private var showShakeLabel = false // Show "Shake Now" label
    @State private var isShakingAnimation = false // Trigger card shake animation
    @StateObject private var motionManager = MotionManager()
    
    @State private var statusText = "Hold your finger in on the deck of cards and shake the phone to shuffle the cards!"


    var body: some View {
        VStack {
            Text(statusText)
                .gridCellAnchor(.center)
                .navigationTitle("Cards Shuffling")

            if showShakeLabel {
                Text("Shake Now!")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding()
            }

            Image(.deckOfCard)
                .resizable()
                .frame(width: 300, height: 300, alignment: .bottom)
                .rotationEffect(
                    isShakingAnimation ? Angle.degrees(-10) : Angle.degrees(0)
                )
                .offset(x: isShakingAnimation ? -10 : 0)
                .animation(
                    isShakingAnimation
                        ? Animation.easeInOut(duration: 0.1).repeatForever(autoreverses: true)
                        : .default,
                    value: isShakingAnimation
                )
                .onLongPressGesture(minimumDuration: 1, maximumDistance: 50, pressing: { isPressing in
                    if isPressing {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        isHoldingCard = true
                        showShakeLabel = true
                        motionManager.startShakeDetection {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            print("Shaking detected!")
                            isShakingAnimation = true
                            statusText = "Shuffling the cards..."
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                isShakingAnimation = false
                            }
                            showShakeLabel = false
                            isHoldingCard = false
                            motionManager.stopShakeDetection()
                        }
                    } else {
                        statusText = "Hold your finger in on the deck of cards and shake the phone to shuffle the cards!"
                        isHoldingCard = false
                        showShakeLabel = false
                        motionManager.stopShakeDetection()
                    }
                }, perform: {})
        }
    }
}

class MotionManager: ObservableObject {
    private var motion = CMMotionManager()
    private let queue = OperationQueue()
    private var isDetectingShake = false

    func startShakeDetection(onShake: @escaping () -> Void) {
        guard motion.isAccelerometerAvailable else { return }
        if isDetectingShake { return } 
        isDetectingShake = true

        motion.accelerometerUpdateInterval = 0.1
        motion.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let self = self, let acceleration = data?.acceleration else { return }

            let threshold = 2.5
            if abs(acceleration.x) > threshold || abs(acceleration.y) > threshold || abs(acceleration.z) > threshold {
                DispatchQueue.main.async {
                    onShake()
                    self.stopShakeDetection()
                }
            }
        }
    }

    func stopShakeDetection() {
        guard isDetectingShake else { return }
        motion.stopAccelerometerUpdates()
        isDetectingShake = false
    }
}



