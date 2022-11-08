//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import Combine
import OSLog
import MatomoTracker

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
//    let persistenceController = PersistenceController.shared
    
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
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var cancellable = Set<AnyCancellable>()
    
    let persistentStore: PersistentStore
    let shared: MSI
    
    let scheme = MarlinScheme()
    var appState: AppState
    
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    @State var loading = false
    
    init() {
        // set up default user defaults
        UserDefaults.registerMarlinDefaults()
        shared = MSI.shared
        appState = MSI.shared.appState
        persistentStoreLoadedPub.sink { notification in
            NSLog("Persistent store loaded, load all data")
            MSI.shared.loadAllData()
        }
        .store(in: &cancellable)
        persistentStore = PersistenceController.shared
        
        UNUserNotificationCenter.current().delegate = appDelegate
    }

    var body: some Scene {
        WindowGroup {
            MarlinView()
                .environmentObject(appState)
                .environment(\.managedObjectContext, persistentStore.viewContext)
                .background(Color.surfaceColor)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidEnterBackground(_ application: UIApplication) {
        MatomoTracker.shared.dispatch()
    }
    
    public var backgroundCompletionHandler: (() -> Void)? = nil
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        backgroundCompletionHandler = completionHandler
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler else {
            return
        }
        backgroundCompletionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let presentationOption: UNNotificationPresentationOptions = [.sound, .banner, .list]
        completionHandler(presentationOption)
    }
}
