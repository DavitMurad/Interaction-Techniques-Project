//
//  GestureView.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 27.02.25.
//


import SwiftUI
import UIKit

struct GestureView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GestureViewController {
        let storyboard = UIStoryboard(name: "HandGestureStoryboard", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(identifier: "GestureViewController") as? GestureViewController else {
            fatalError("GestureViewController not found in HandGestureStoryBoard")
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: GestureViewController, context: Context) {
    }
}
