//
//  GazingView.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 22.02.25.
//

import SwiftUI
import UIKit

struct GazingView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> GazingViewController {
        let storyboard = UIStoryboard(name: "GazingStoryboard", bundle: nil)
        
        guard let viewController = storyboard.instantiateViewController(identifier: "GazingViewController") as? GazingViewController else {
            fatalError("GazingViewController not found in GazingStoryBoard")
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: GazingViewController, context: Context) {
    }
}
