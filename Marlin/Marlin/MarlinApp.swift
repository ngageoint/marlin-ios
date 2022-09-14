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
    @Published var loadingDataSource: [String : Bool] = [:]
}

struct MarlinApp: App {
    
    let viewContext = PersistenceController.shared.container.viewContext
    let shared = MSI.shared
    
    let scheme = MarlinScheme()
    let appState = AppState()
    
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
    @State var loading = false
    
    init() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
//            if let error = error {
//                // Handle the error here.
//            }
            
            // Enable or disable features based on the authorization.
        }
        
        // set up default user defaults
        UserDefaults.registerMarlinDefaults()
    }

    var body: some Scene {
        WindowGroup {
            MarlinView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, viewContext)
                .background(Color.surfaceColor)
                .onAppear {
                    if PersistenceController.shared.isLoaded, !loading {
                        NSLog("Marlin view appear, PersistenceController is loaded, load data")
                        loading = true
                        shared.loadAllData(appState: appState)
                    }
                }
                .onReceive(persistentStoreLoadedPub) { output in
                    if !loading {
                        NSLog("Marlin view recieve notification, PersistenceController is loaded, load data")
                        loading = true
                        shared.loadAllData(appState: appState)
                    }
                }
        }
    }
}
