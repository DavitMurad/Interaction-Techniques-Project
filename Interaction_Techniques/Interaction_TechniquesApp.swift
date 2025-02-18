//
//  Interaction_TechniquesApp.swift
//  Interaction_Techniques
//
//  Created by Davit Muradyan on 18.02.25.
//

import SwiftUI

@main
struct Interaction_TechniquesApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
