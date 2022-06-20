//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI

@main
struct AppLauncher {
    
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            MarlinApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        print("doing the tests")
    }
    
    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}

struct MarlinApp: App {
    
    let persistenceController = PersistenceController.shared
    let shared = MSI.shared
    
    let scheme = MarlinScheme()
    
    init() {
        let newestAsam = try? persistenceController.container.viewContext.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)])
        shared.loadAsams(date: newestAsam?.dateString)
        
        let newestModu = try? persistenceController.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
        shared.loadModus(date: newestModu?.dateString)
        
    }

    var body: some Scene {
        WindowGroup {
            MarlinTabView(itemWrapper: ItemWrapper())
                .environmentObject(scheme)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
