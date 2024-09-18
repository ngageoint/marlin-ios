//
//  MSI.swift
//  Marlin
//
//  Created by Daniel Barela on 6/3/22.
//

import Foundation
import Alamofire
import OSLog
import CoreData
import SwiftUI

public class MSI {

    var moduInitializer: ModuInitializer?
    var portInitializer: PortInitializer?
    var lightInitializer: LightInitializer?
    var radioBeaconInitializer: RadioBeaconInitializer?
    var differentialGPSStationInitializer: DGPSStationInitializer?
    var publicationInitializer: PublicationInitializer?
    var navigationalWarningInitializer: NavigationalWarningInitializer?
    var noticeToMarinersInitializer: NoticeToMarinersInitializer?

    func addRepositories(
        routeRepository: RouteRepository
    ) {
        moduInitializer = ModuInitializer()
        portInitializer = PortInitializer()
        lightInitializer = LightInitializer()
        radioBeaconInitializer = RadioBeaconInitializer()
        differentialGPSStationInitializer = DGPSStationInitializer()
        publicationInitializer = PublicationInitializer()
        navigationalWarningInitializer = NavigationalWarningInitializer()
        noticeToMarinersInitializer = NoticeToMarinersInitializer()
        registerBackgroundHandler()
    }

    var loading: Bool {
        for dataSource in DataSourceDefinitions.allCases 
        where self.appState.loadingDataSource[dataSource.definition.key] == true {
            return true
        }
        return false
    }
    
    static let shared = MSI()
    let appState = AppState()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    var manager = ServerTrustManager(evaluators: [
        "msi.nga.mil": DefaultTrustEvaluator(validateHost: true),
        "osm-nominatim.gs.mil": DefaultTrustEvaluator(validateHost: true)
    ])
    var loadAllDataTime: Date?
    lazy var session: Session = {
        
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        
        return Session(configuration: configuration, serverTrustManager: manager)
    }()

    lazy var backgroundLoadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Data load queue"
        return queue
    }()

    lazy var capabilitiesSession: Session = {
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        let manager = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
        return Session(configuration: configuration, serverTrustManager: manager)
    }()

    func registerBackgroundHandler() {
        moduInitializer?.registerBackgroundHandler()
        portInitializer?.registerBackgroundHandler()
        lightInitializer?.registerBackgroundHandler()
        radioBeaconInitializer?.registerBackgroundHandler()
        differentialGPSStationInitializer?.registerBackgroundHandler()
        publicationInitializer?.registerBackgroundHandler()
        navigationalWarningInitializer?.registerBackgroundHandler()
        noticeToMarinersInitializer?.registerBackgroundHandler()
    }

    func onChangeOfScenePhase(_ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // this will ensure these notifications are not sent since the user should have seen them
            appState.dsBatchImportNotificationsPending = [:]
            scheduleAppRefresh()
        case .active:
            Task {
                await MSI.shared.loadAllData()
            }
        default:
            break
        }
    }
    
    func scheduleAppRefresh() {
        moduInitializer?.scheduleRefresh()
        portInitializer?.scheduleRefresh()
        lightInitializer?.scheduleRefresh()
        radioBeaconInitializer?.scheduleRefresh()
        differentialGPSStationInitializer?.scheduleRefresh()
        publicationInitializer?.scheduleRefresh()
        navigationalWarningInitializer?.scheduleRefresh()
        noticeToMarinersInitializer?.scheduleRefresh()
    }
    
    func loadAllData() async {
        // if there was a previous load, and it was less than 5 minutes ago just chill
        if let loadAllDataTime = loadAllDataTime, loadAllDataTime.timeIntervalSince(Date()) < (5 * 60) {
            NSLog("Already loaded data within the last 5 minutes.  Let's not")
            return
        }
        loadAllDataTime = Date()
        NSLog("Load all data")
        
        await moduInitializer?.fetch()
        await portInitializer?.fetch()
        await lightInitializer?.fetch()
        await radioBeaconInitializer?.fetch()
        await differentialGPSStationInitializer?.fetch()
        await publicationInitializer?.fetch()
        await navigationalWarningInitializer?.fetch()
        await noticeToMarinersInitializer?.fetch()
    }
    
    @objc func managedObjectContextObjectChangedObserver(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            if let dataSourceItem = inserts.first as? (any DataSource) {
                var allLoaded = true
                for (dataSource, loading) in self.appState.loadingDataSource {
                    if loading && type(of: dataSourceItem).definition.key != dataSource {
                        allLoaded = false
                    }
                }
                if allLoaded {
                    PersistenceController.current.removeViewContextObserver(
                        self,
                        name: .NSManagedObjectContextObjectsDidChange)
                }
                DispatchQueue.main.async {
                    self.appState.loadingDataSource[type(of: dataSourceItem).definition.key] = false
                    
                    if allLoaded {
                        UserDefaults.standard.initialDataLoaded = true
                        self.loadAllDataTime = nil
                        Task {
                            await self.loadAllData()
                        }
                    }
                }
            }
        }
    }
}
