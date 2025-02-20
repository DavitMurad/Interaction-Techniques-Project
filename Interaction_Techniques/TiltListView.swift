//
//  Tilting.swift
//  sensorHCI
//
//  Created by Davit Muradyan on 16.02.25.
//

import SwiftUI
import CoreMotion
import Speech


struct TiltListView: View {
    @StateObject private var motionManager = MotionManager_Tilting()
    @StateObject private var speechRecognizer = SpeechRecognizerManager()

    @State private var selectedIndex = 0
    @State private var selectedItemLabel: String = "None"
    @State private var isInteractionActive = false
    @State private var showingStartAlert = false

    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

    var body: some View {
        VStack {
            Text("Tilt & Voice Selection Demo")
                .font(.title2)

            List(0..<items.count, id: \.self) { index in
                Text(items[index])
                    .padding()
                    .background(selectedIndex == index ? Color.blue.opacity(0.3) : Color.clear)
                    .cornerRadius(8)
            }

            Text("Selected Item: \(selectedItemLabel)")
                .font(.headline)
                .padding()

            Button("Start Interaction") {
                showingStartAlert = true
                isInteractionActive = true
                startInteraction()
            }
            .padding()
            .disabled(isInteractionActive)
        }
        .alert("Start Interaction", isPresented: $showingStartAlert) {
            Button("OK") {
                showingStartAlert = false
            }
        } message: {
            Text("Tilt your device up or down to highlight an item, then say 'Select' to choose it.")
        }
        .onChange(of: speechRecognizer.detectedCommand) { newCommand in
            handleVoiceCommand(newCommand)
        }
    }

    private func startInteraction() {
        motionManager.startTiltDetection { direction in
            switch direction {
            case .up:
                if selectedIndex > 0 {
                    withAnimation {
                        selectedIndex -= 1
                    }
                }
            case .down:
                if selectedIndex < items.count - 1 {
                    withAnimation {
                        selectedIndex += 1
                    }
                }
            case .none:
                break
            }
        }

        speechRecognizer.startListening()
    }

    private func stopInteraction() {
        motionManager.stopTiltDetection()
        speechRecognizer.stopListening()
        isInteractionActive = false
    }

    private func handleVoiceCommand(_ command: String) {
        if command.contains("select") {
            selectedItemLabel = items[selectedIndex]
            stopInteraction()
        }
    }
}

class MotionManager_Tilting: ObservableObject {
    private var motion = CMMotionManager()
    private let queue = OperationQueue()
    private var isDetectingTilt = false

    enum TiltDirection {
        case up
        case down
        case none
    }

    func startTiltDetection(onTilt: @escaping (TiltDirection) -> Void) {
        guard motion.isAccelerometerAvailable else { return }

        if isDetectingTilt { return }
        isDetectingTilt = true

        motion.accelerometerUpdateInterval = 0.2
        motion.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let acceleration = data?.acceleration else { return }

            DispatchQueue.main.async {
                if acceleration.y < -0.4 {
                    onTilt(.down)
                } else if acceleration.y > 0.4 {
                    onTilt(.up)
                } else {
                    onTilt(.none)
                }
            }
        }
    }

    func stopTiltDetection() {
        motion.stopAccelerometerUpdates()
        isDetectingTilt = false
    }
}


class SpeechRecognizerManager: ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var detectedCommand: String = ""

    func startListening() {
        requestAuthorization { [weak self] authorized in
            guard authorized else { return }
            self?.startRecognizing()
        }
    }

    func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }

    private func startRecognizing() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let result = result else {
                print("Speech recognition error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let spokenText = result.bestTranscription.formattedString.lowercased()
            self?.detectedCommand = spokenText

            if result.isFinal {
                print("Final recognized text: \(spokenText)")
                self?.processCommand(spokenText)
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.reset()
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func processCommand(_ command: String) {
        detectedCommand = command // Update for UI or other listeners
        // You can send this to the TiltListView if needed via a callback or state
    }
}
