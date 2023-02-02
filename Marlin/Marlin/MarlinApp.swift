//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import Combine
import OSLog
import BackgroundTasks

@main
struct AppLauncher {
    
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            if #available(iOS 16, *) {
                MarlinApp.main()
            } else {
                NonBackgroundMarlinApp.main()
            }
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
//    let persistenceController = PersistenceController.shared
    
    init() {
        UserDefaults.standard.set(false, forKey: "metricsEnabled")
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

@available (iOS 16, *)
struct MarlinApp: App {
    @Environment(\.scenePhase) private var phase
    
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
                .onAppear {
                    let request = BGAppRefreshTaskRequest(identifier: "mil.nga.msi.refresh")
                    // Fetch no earlier than 1 hour from now
                    request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
                    do {
                        try BGTaskScheduler.shared.submit(request) // Mark 3
                        print("Background Task Scheduled!")
                    } catch(let error) {
                        print("Scheduling Error \(error.localizedDescription)")
                    }
                }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .background: scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("mil.nga.msi.refresh")) {
            await scheduleAppRefresh()
            MSI.shared.loadAllData()

        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "mil.nga.msi.refresh")
        // Fetch no earlier than 1 hour from now
        request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Metrics.shared.dispatch()
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

// remove this when we support ios 16 +
struct NonBackgroundMarlinApp: App {
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
