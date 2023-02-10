//
//  MarlinApp.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import Combine
import OSLog

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
    @Published var dataSourceBatchImportNotificationsPending: [String: [DataSourceUpdatedNotification]] = [:]
    @Published var lastNotificationRequestDate: Date = Date()
    @Published var consolidatedDataLoadedNotification: String?
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
    @AppStorage("initialDataLoaded") var initialDataLoaded: Bool = false

    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    let batchImportCompletePub = NotificationCenter.default.publisher(for: .BatchUpdateComplete)
        .receive(on: RunLoop.main)
        .compactMap {
            $0.object as? BatchUpdateComplete
        }
    
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
                .onReceive(appState.$lastNotificationRequestDate) { newValue in
                    var insertsPerDataSource: [String : Int] = [:]
                    
                    for (_, importNotifications) in appState.dataSourceBatchImportNotificationsPending {
                        for notification in importNotifications {
                            let inserts: Int = insertsPerDataSource[notification.key] ?? 0
                            insertsPerDataSource[notification.key] = inserts + (notification.inserts ?? 0)
                        }
                    }
                    
                    var notificationStrings: [String] = []
                    
                    for (dataSourceKey, inserts) in insertsPerDataSource {
                        let dataSourceItem = DataSourceList().allTabs.first { item in
                            item.key == dataSourceKey
                        }
                        if inserts != 0 {
                            notificationStrings.append("\(inserts) new \(dataSourceItem?.dataSource.fullDataSourceName ?? "")")
                        }
                    }
                    if !notificationStrings.isEmpty {
                        appState.consolidatedDataLoadedNotification = notificationStrings.joined(separator: "\n")
                    } else {
                        appState.consolidatedDataLoadedNotification = nil
                    }
                }
                .onReceive(appState.$consolidatedDataLoadedNotification.debounce(for: .seconds(2), scheduler: RunLoop.main)) { newValue in
                    if phase == .background {
                        if let newValue = newValue {
                            appState.dataSourceBatchImportNotificationsPending = [:]
                            let center = UNUserNotificationCenter.current()
                            let content = UNMutableNotificationContent()
                            content.title = NSString.localizedUserNotificationString(forKey: "New Marlin Data", arguments: nil)
                            content.body = NSString.localizedUserNotificationString(forKey: newValue, arguments: nil)
                            content.sound = UNNotificationSound.default
                            content.categoryIdentifier = "mil.nga.msi"
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
                            let request = UNNotificationRequest.init(identifier: UUID().uuidString, content: content, trigger: trigger)
                            center.add(request)
                        }
                    }
                }
                .onReceive(batchImportCompletePub) { batchUpdateComplete in
                    let updates = batchUpdateComplete.dataSourceUpdates
                    for update in updates {
                        let dataSourceKey = update.key
                        var pending: [DataSourceUpdatedNotification] = appState.dataSourceBatchImportNotificationsPending[dataSourceKey] ?? []
                        pending.append(update)
                        appState.dataSourceBatchImportNotificationsPending[dataSourceKey] = pending
                        
                    }
                    appState.lastNotificationRequestDate = Date()
                }
        }
        .onChange(of: phase) { newPhase in
            MSI.shared.onChangeOfScenePhase(newPhase)
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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        MSI.shared.registerBackgroundHandler()
        return true
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
