//
//  GazingViewController.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 22.02.25.
//
import UIKit
import ARKit
import AudioToolbox

class GazingViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var selectedItemLabel: UILabel!
    
    var arSession = ARSession()
    var selectedIndex: Int? = nil
    let items = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    
    var gazeSelectionTimer: Timer?
    var dwellDuration: TimeInterval = 1.5
    var currentlyGazingAtIndex: Int? = nil
    var lastBlinkTime: Date?
    var blinkCooldown: TimeInterval = 0.5
    
    // For blink stabilization
    var lastStableCursorPosition: CGPoint?
    var isBlinking: Bool = false
    var blinkStabilizationDuration: TimeInterval = 0.3
    
    let cursorView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        view.backgroundColor = .red
        view.layer.cornerRadius = 15
        view.alpha = 0.7
        return view
    }()
    
    let progressRing: CAShapeLayer = {
        let shape = CAShapeLayer()
        shape.strokeColor = UIColor.blue.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 3.0
        shape.lineCap = .round
        shape.strokeEnd = 0.0
        return shape
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupCursor()
        setupARSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let path = UIBezierPath(arcCenter: CGPoint(x: 15, y: 15),
                                radius: 17,
                                startAngle: -(.pi / 2),
                                endAngle: 2 * .pi - (.pi / 2),
                                clockwise: true)
        progressRing.path = path.cgPath
    }
    
    func setupTableView() {
        listTableView.dataSource = self
        listTableView.delegate = self
        listTableView.register(GazingTableViewCell.self, forCellReuseIdentifier: "GazingCell")
        listTableView.rowHeight = 120
        listTableView.separatorStyle = .singleLine
        listTableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    }
    
    func setupCursor() {
        view.addSubview(cursorView)
        cursorView.layer.addSublayer(progressRing)
        lastStableCursorPosition = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    func setupARSession() {
        guard ARFaceTrackingConfiguration.isSupported else {
            print("❌ Face tracking not supported on this device")
            return
        }
        
        let configuration = ARFaceTrackingConfiguration()
        arSession.delegate = self
        arSession.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func confirmSelection(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        
        selectedIndex = index
        selectedItemLabel.text = "Selected: \(items[index])"
        
        UIView.animate(withDuration: 0.3, animations: {
            self.listTableView.reloadData()
        })
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func startGazeTimer(for index: Int) {
        gazeSelectionTimer?.invalidate()
        
        progressRing.strokeEnd = 0.0
        
        currentlyGazingAtIndex = index
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = dwellDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        progressRing.add(animation, forKey: "progressAnimation")
        
        gazeSelectionTimer = Timer.scheduledTimer(withTimeInterval: dwellDuration, repeats: false) { [weak self] _ in
            guard let self = self, let currentIndex = self.currentlyGazingAtIndex else { return }
            self.highlightCell(at: currentIndex)
        }
    }
    
    func cancelGazeTimer() {
        gazeSelectionTimer?.invalidate()
        gazeSelectionTimer = nil
        currentlyGazingAtIndex = nil
        progressRing.strokeEnd = 0.0
        progressRing.removeAllAnimations()
    }
    
    func highlightCell(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        
        if let cell = listTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? GazingTableViewCell {
            cell.setHighlighted(true, animated: true)
        }
    }
    
    func handleBlink() {
        let now = Date()
        if let lastBlink = lastBlinkTime, now.timeIntervalSince(lastBlink) < blinkCooldown {
            return
        }
        lastBlinkTime = now
        
        if !isBlinking {
            lastStableCursorPosition = cursorView.center
            isBlinking = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + blinkStabilizationDuration) {
                self.isBlinking = false
            }
        }
        
        if let index = currentlyGazingAtIndex {
            confirmSelection(at: index)
            
            cursorView.backgroundColor = .green
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.cursorView.backgroundColor = .red
            }
        }
    }
}

extension GazingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GazingCell", for: indexPath) as? GazingTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(text: items[indexPath.row], isSelected: indexPath.row == selectedIndex)
        
        return cell
    }
}

extension GazingViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        
        DispatchQueue.main.async {
            self.processFaceAnchor(faceAnchor)
        }
    }
    
    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        let blendShapes = faceAnchor.blendShapes
        if let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
           let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float {
            let currentlyBlinking = eyeBlinkLeft > 0.6 && eyeBlinkRight > 0.6
            
            if currentlyBlinking {
                DispatchQueue.main.async {
                    self.handleBlink()
                }
                return
            }
        }
        
        if !isBlinking {
            guard let leftEyeTransform = faceAnchor.blendShapes[.eyeLookOutLeft] as? Float,
                  let rightEyeTransform = faceAnchor.blendShapes[.eyeLookOutRight] as? Float else {
                return
            }
            
            let leftGaze = faceAnchor.leftEyeTransform.columns.2
            let rightGaze = faceAnchor.rightEyeTransform.columns.2
            
            let averageGazeX = (leftGaze.x + rightGaze.x) / 2
            let averageGazeY = (leftGaze.y + rightGaze.y) / 2
            
            DispatchQueue.main.async {
                self.updateCursorPosition(eyeLookX: averageGazeX, eyeLookY: averageGazeY)
            }
        }
    }
    
    func convertEyePositionToScreen(_ eyePosition: SCNVector3) -> CGPoint {
        let screenWidth = view.bounds.width
        let screenHeight = view.bounds.height
        
        let scaleX: CGFloat = 800.0
        let scaleY: CGFloat = 600.0
        
        let x = screenWidth / 2 + CGFloat(eyePosition.x) * scaleX
        let y = screenHeight / 2 - CGFloat(eyePosition.y) * scaleY
        
        return CGPoint(x: x, y: y)
    }
    
    func updateCursorPosition(eyeLookX: Float, eyeLookY: Float) {
        if isBlinking {
            return
        }
        
        let sensitivity: CGFloat = 1000
        
        let newX = view.bounds.midX - CGFloat(eyeLookX) * sensitivity
        let newY = view.bounds.midY - CGFloat(eyeLookY) * sensitivity
        
        let smoothingFactor: CGFloat = 0.7
        let smoothedX = (newX * smoothingFactor) + (cursorView.center.x * (1 - smoothingFactor))
        let smoothedY = (newY * smoothingFactor) + (cursorView.center.y * (1 - smoothingFactor))
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.cursorView.center = CGPoint(x: smoothedX, y: smoothedY)
            self.lastStableCursorPosition = self.cursorView.center
        }, completion: { _ in
            self.checkGazeOnTableView()
        })
    }
    
    func checkGazeOnTableView() {
        let cursorPositionInTableView = view.convert(cursorView.center, to: listTableView)
        
        if let indexPath = listTableView.indexPathForRow(at: cursorPositionInTableView) {
            if currentlyGazingAtIndex != indexPath.row {
                startGazeTimer(for: indexPath.row)
            }
        } else {
            cancelGazeTimer()
        }
    }
}
