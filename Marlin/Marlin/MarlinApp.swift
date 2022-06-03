//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI

@main
struct MarlinApp: App {
    
    let persistenceController = PersistenceController.shared
    let shared = MSI.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
