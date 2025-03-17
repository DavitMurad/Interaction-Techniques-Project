README

Mobile HCI Project

This project explores two alternative interaction techniques for mobile interfaces:

Tilt & Voice Input: Allows users to navigate a list by tilting their device and confirming selections via voice commands.

Eye-Tracking & Blink Detection: Uses ARKit to track gaze and confirm selections through blinking.

Features

Motion & Voice-Based Selection: Uses CoreMotion and SpeechRecognizer for hands-free interaction.

Gaze & Blink Detection: Utilizes ARKit for eye-tracking and selection confirmation.

Haptic & Visual Feedback: Enhances user experience by providing real-time feedback.

Technologies Used

SwiftUI (for Tilt & Voice Input UI)

UIKit & ARKit (for Eye-Tracking & Blink Detection)

CoreMotion (for tilt-based selection)

SFSpeechRecognizer (for voice commands)

Setup & Installation

Clone the repository:

git clone <repository_url>

Open the project in Xcode.

Ensure you have an iOS device with FaceID for ARKit tracking.

Build and run the project on a physical device (ARKit is not supported on the simulator).

Usage

Tilt & Voice Input:

Press "Start Interaction."

Tilt the device up/down to navigate the list.

Say "Select" to confirm a choice.

Receive feedback via haptic response.

Eye-Tracking & Blink Detection:

Open the gaze-based selection page.

Move your eyes to highlight an item.

Hold gaze for 2 seconds to trigger selection.

Blink to confirm.

Cursor stabilization prevents misalignment.

Known Issues

ARKit Tracking Limitations: Cursor drift and difficulty selecting upper-screen elements.

Speech Recognition Sensitivity: Noisy environments may reduce accuracy.

Tilt Sensitivity Adjustments: Some users may require custom sensitivity settings.

Future Improvements

Fine-tuning ARKit gaze tracking.

Implementing adjustable tilt sensitivity.

Improving blink detection accuracy.

License

This project is licensed under the MIT License.
