//
//  ContentView.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 18.02.25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        NavigationStack {
            List {
                NavigationLink("Cards Shuffling") {
                    Cards()
                }
                NavigationLink("Tilting & Voice Command") {
                    TiltListView()
                }
                NavigationLink("Gaze detection and Eye Blink") {
                    GazingView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
