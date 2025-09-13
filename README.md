# Mobile HCI Project - Interaction Techniques
# About 🤌
https://github.com/user-attachments/assets/051d0493-86e3-43b3-8b09-d95db2a62fcd


This project explores two alternative interaction techniques for mobile interfaces designed to push beyond traditional tap-based controls:

Tilt & Voice Input – navigate lists by tilting the device and confirm selections via voice commands

Eye-Tracking & Blink Detection – use gaze to highlight items and blink to confirm

The goal? Expand accessibility, explore futuristic UIs, and learn how Apple’s sensors and frameworks can open up new interaction possibilities.

# Technologies Used
SwiftUI – built the UI for tilt + voice interaction

UIKit + ARKit – implemented eye-tracking and blink detection with camera input

CoreMotion – captured real-time tilt motion to drive selection

SFSpeechRecognizer – used Apple’s native speech API to detect confirmation commands

Haptics & Visual Feedback – provided real-time confirmation cues and a tactile experience

Features

🎮 Motion & Voice-Based Selection – navigate and confirm selections hands-free

👀 Gaze & Blink Detection – highlight with gaze, confirm with blink using ARKit eye-tracking

📳 Haptic + Visual Feedback – improves accessibility and user confidence

🚫 Tap-free Interaction – ideal for hands-busy or accessibility-focused contexts


# Usage
Usage
🌀 Tilt & Voice Input

1. Tap Start Interaction

2. Tilt your device up/down to navigate the list

3. Say "Select" to confirm your choice

4. Get instant haptic feedback

👁️ Eye-Tracking & Blink Detection

1. Navigate to the Gaze Interaction screen

2. Move your eyes to highlight an element

3. Hold gaze for 2 seconds to trigger selection

4. Blink to confirm

5. Gaze cursor is stabilized to reduce misalignment

# Challenges & Learnings

ARKit Drift - eye-tracking occasionally loses precision, especially on top-of-screen elements

Speech Sensitivity - accuracy drops in noisy environments

Tilt Sensitivity - hardcoded thresholds may not suit every user; personalization is needed

# Future Improvements

Improve ARKit precision - reduce drift and increase accuracy in blink detection

Adjustable tilt controls - customizable sensitivity for better user control

More robust gaze detection - smoother highlighting and selection confirmation
License

