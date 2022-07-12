//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import Combine

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

class AppState: ObservableObject {
    @Published var popToRoot: Bool = false
}

struct MarlinApp: App {
    
    let persistenceController = PersistenceController.shared
    let shared = MSI.shared
    
    let scheme = MarlinScheme()
    
    init() {
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
        
        // set up default user defaults
        UserDefaults.registerMarlinDefaults()
        
        let newestAsam = try? persistenceController.container.viewContext.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)])
        shared.loadAsams(date: newestAsam?.dateString)
        
        let newestModu = try? persistenceController.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
        shared.loadModus(date: newestModu?.dateString)
        
        shared.loadNavigationalWarnings()
        
//        shared.loadLights()
    }

    var body: some Scene {
        WindowGroup {
            MarlinTabView(itemWrapper: ItemWrapper())
                .environmentObject(scheme)
                .environmentObject(AppState())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
