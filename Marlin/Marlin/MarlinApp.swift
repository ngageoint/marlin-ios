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
            MarlinApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {    
    init() {
        UserDefaults.standard.set(false, forKey: "metricsEnabled")
        print("doing the tests")
    }
    
    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}

class AppState: ObservableObject {
    @Published var loadingDataSource: [String: Bool] = [:]
    @Published var dsBatchImportNotificationsPending: [String: [DataSourceUpdatedNotification]] = [:]
    @Published var lastNotificationRequestDate: Date = Date()
    @Published var consolidatedDataLoadedNotification: String?
}

struct PhaseWatcher: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) private var phase
    
    let batchImportCompletePub = NotificationCenter.default.publisher(for: .BatchUpdateComplete)
        .receive(on: RunLoop.main)
        .compactMap {
            $0.object as? BatchUpdateComplete
        }
    
    var body: some View {
        Self._printChanges()
        
        return EmptyView()
            .onChange(of: phase) { newPhase in
                MSI.shared.onChangeOfScenePhase(newPhase)
            }
            .onReceive(appState.$lastNotificationRequestDate) { _ in
                var insertsPerDataSource: [String: Int] = [:]
                
                for (_, importNotifications) in appState.dsBatchImportNotificationsPending {
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
                        notificationStrings
                            .append("\(inserts) new \(dataSourceItem?.dataSource.fullName ?? "")")
                    }
                }
                if !notificationStrings.isEmpty {
                    appState.consolidatedDataLoadedNotification = notificationStrings.joined(separator: "\n")
                } else {
                    appState.consolidatedDataLoadedNotification = nil
                }
            }
            .onReceive(appState.$consolidatedDataLoadedNotification.debounce(
                for: .seconds(2),
                scheduler: RunLoop.main)
            ) { newValue in
                if phase == .background {
                    if let newValue = newValue {
                        appState.dsBatchImportNotificationsPending = [:]
                        let center = UNUserNotificationCenter.current()
                        let content = UNMutableNotificationContent()
                        content.title = NSString.localizedUserNotificationString(
                            forKey: "New Marlin Data",
                            arguments: nil
                        )
                        content.body = NSString.localizedUserNotificationString(forKey: newValue, arguments: nil)
                        content.sound = UNNotificationSound.default
                        content.categoryIdentifier = "mil.nga.msi"
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
                        let request = UNNotificationRequest.init(
                            identifier: UUID().uuidString,
                            content: content,
                            trigger: trigger
                        )
                        center.add(request)
                    }
                }
            }
            .onReceive(batchImportCompletePub) { batchUpdateComplete in
                let updates = batchUpdateComplete.dataSourceUpdates
                for update in updates {
                    let dataSourceKey = update.key
                    var pending: [DataSourceUpdatedNotification] = 
                    appState.dsBatchImportNotificationsPending[dataSourceKey] ?? []
                    pending.append(update)
                    appState.dsBatchImportNotificationsPending[dataSourceKey] = pending

                }
                appState.lastNotificationRequestDate = Date()
            }
    }
}

@available (iOS 16, *)
struct MarlinApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    var cancellable = Set<AnyCancellable>()
    
    let persistentStore: PersistentStore
    let shared: MSI
    
    let scheme = MarlinScheme()
    var appState: AppState
    
    @StateObject var dataSourceList: DataSourceList = DataSourceList()
    var bookmarkRepository: BookmarkRepository
    var asamRepository: AsamRepository
    var moduRepository: ModuRepository
    var portRepository: PortRepository
    var differentialGPSStationRepository: DGPSStationRepository
    var lightRepository: LightRepository
    var radioBeaconRepository: RadioBeaconRepository
    var publicationRepository: PublicationRepository
    var navigationalWarningRepository: NavigationalWarningRepository
    var noticeToMarinersRepository: NoticeToMarinersRepository
    var userPlaceRepository: UserPlaceRepository

    var routeRepository: RouteRepository
    var routeWaypointRepository: RouteWaypointRepository

    var asamsTileRepository: AsamsTileRepository
    var modusTileRepository: ModusTileRepository
    var portsTileRepository: PortsTileRepository
    var lightsTileRepository: LightsTileRepository
    var radioBeaconsTileRepository: RadioBeaconsTileRepository
    var differentialGPSStationsTileRepository: DifferentialGPSStationsTileRepository
    var navigationalWarningsMapFeatureRepository: NavigationalWarningsMapFeatureRepository

    private var router: MarlinRouter = MarlinRouter()

    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)

    init() {
        shared = MSI.shared
        appState = MSI.shared.appState
        persistentStore = PersistenceController.shared

        asamRepository = AsamRepository(
            localDataSource: AsamCoreDataDataSource(),
            remoteDataSource: AsamRemoteDataSource()
        )
        moduRepository = ModuRepository(
            localDataSource: ModuCoreDataDataSource(),
            remoteDataSource: ModuRemoteDataSource()
        )
        portRepository = PortRepository(
            localDataSource: PortCoreDataDataSource(),
            remoteDataSource: PortRemoteDataSource()
        )
        differentialGPSStationRepository = DGPSStationRepository(
            localDataSource: DGPSStationCoreDataDataSource(),
            remoteDataSource: DGPSStationRemoteDataSource()
        )
        lightRepository = LightRepository(
            localDataSource: LightCoreDataDataSource(),
            remoteDataSource: LightRemoteDataSource()
        )
        radioBeaconRepository = RadioBeaconRepository(
            localDataSource: RadioBeaconCoreDataDataSource(),
            remoteDataSource: RadioBeaconRemoteDataSource()
        )
        publicationRepository = PublicationRepository(
            localDataSource: PublicationCoreDataDataSource(),
            remoteDataSource: PublicationRemoteDataSource()
        )
        navigationalWarningRepository = NavigationalWarningRepository(
            localDataSource: NavigationalWarningCoreDataDataSource(),
            remoteDataSource: NavigationalWarningRemoteDataSource()
        )
        noticeToMarinersRepository = NoticeToMarinersRepository(
            localDataSource: NoticeToMarinersCoreDataDataSource(),
            remoteDataSource: NoticeToMarinersRemoteDataSource()
        )
        userPlaceRepository = UserPlaceRepository(localDataSource: UserPlaceCoreDataDataSource())

        routeRepository = RouteRepository(localDataSource: RouteCoreDataDataSource())
        routeWaypointRepository = RouteWaypointRepository(
            localDataSource: RouteWaypointCoreDataDataSource(context: persistentStore.viewContext))

        bookmarkRepository = BookmarkRepository(
            localDataSource: BookmarkCoreDataDataSource(),
            asamRepository: asamRepository,
            dgpsRepository: differentialGPSStationRepository,
            lightRepository: lightRepository,
            moduRepository: moduRepository,
            portRepository: portRepository,
            radioBeaconRepository: radioBeaconRepository,
            noticeToMarinersRepository: noticeToMarinersRepository,
            publicationRepository: publicationRepository
        )

        asamsTileRepository = AsamsTileRepository(localDataSource: asamRepository.localDataSource)
        modusTileRepository = ModusTileRepository(localDataSource: moduRepository.localDataSource)
        portsTileRepository = PortsTileRepository(localDataSource: portRepository.localDataSource)
        lightsTileRepository = LightsTileRepository(localDataSource: lightRepository.localDataSource)
        radioBeaconsTileRepository = RadioBeaconsTileRepository(localDataSource: radioBeaconRepository.localDataSource)
        differentialGPSStationsTileRepository = DifferentialGPSStationsTileRepository(
            localDataSource: differentialGPSStationRepository.localDataSource
        )
        navigationalWarningsMapFeatureRepository = NavigationalWarningsMapFeatureRepository(
            localDataSource: navigationalWarningRepository.localDataSource
        )

        MSI.shared.addRepositories(
            asamRepository: asamRepository,
            moduRepository: moduRepository,
            portRepository: portRepository,
            lightRepository: lightRepository,
            radioBeaconRepository: radioBeaconRepository,
            differentialGPSStationRepository: differentialGPSStationRepository,
            publicationRepository: publicationRepository,
            navigationalWarningRepository: navigationalWarningRepository,
            noticeToMarinersRepository: noticeToMarinersRepository,
            routeRepository: routeRepository
        )
        UNUserNotificationCenter.current().delegate = appDelegate

        persistentStoreLoadedPub.sink { _ in
            NSLog("Persistent store loaded, load all data")
            MSI.shared.loadAllData()
        }
        .store(in: &cancellable)
    }

    var body: some Scene {
        WindowGroup {
            MarlinView()
                .background(PhaseWatcher())
                .environmentObject(LocationManager.shared())
                .environmentObject(appState)
                .environmentObject(dataSourceList)
                .environmentObject(bookmarkRepository)
                .environmentObject(asamRepository)
                .environmentObject(moduRepository)
                .environmentObject(lightRepository)
                .environmentObject(portRepository)
                .environmentObject(differentialGPSStationRepository)
                .environmentObject(radioBeaconRepository)
                .environmentObject(routeRepository)
                .environmentObject(routeWaypointRepository)
                .environmentObject(navigationalWarningRepository)
                .environmentObject(publicationRepository)
                .environmentObject(noticeToMarinersRepository)
                .environmentObject(userPlaceRepository)
                .environmentObject(asamsTileRepository)
                .environmentObject(modusTileRepository)
                .environmentObject(portsTileRepository)
                .environmentObject(lightsTileRepository)
                .environmentObject(radioBeaconsTileRepository)
                .environmentObject(differentialGPSStationsTileRepository)
                .environmentObject(navigationalWarningsMapFeatureRepository)
                .environment(\.managedObjectContext, persistentStore.viewContext)
                .environmentObject(router)
                .background(Color.surfaceColor)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Metrics.shared.dispatch()
    }
    
    public var backgroundCompletionHandler: (() -> Void)?
    
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
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let presentationOption: UNNotificationPresentationOptions = [.sound, .banner, .list]
        completionHandler(presentationOption)
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UserDefaults.registerMarlinDefaults()
        MSI.shared.registerBackgroundHandler()
        return true
    }
}
