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

    var asamInitializer: AsamInitializer?
    var moduInitializer: ModuInitializer?
    var portInitializer: PortInitializer?
    var lightInitializer: LightInitializer?
    var radioBeaconInitializer: RadioBeaconInitializer?
    var differentialGPSStationInitializer: DifferentialGPSStationInitializer?
    var electronicPublicationInitializer: ElectronicPublicationInitializer?
    var navigationalWarningInitializer: NavigationalWarningInitializer?
    var noticeToMarinersInitializer: NoticeToMarinersInitializer?

    // swiftlint:disable function_parameter_count
    func addRepositories(
        asamRepository: AsamRepository,
        moduRepository: ModuRepository,
        portRepository: PortRepository,
        lightRepository: LightRepository,
        radioBeaconRepository: RadioBeaconRepository,
        differentialGPSStationRepository: DifferentialGPSStationRepository,
        electronicPublicationRepository: ElectronicPublicationRepository,
        navigationalWarningRepository: NavigationalWarningRepository,
        noticeToMarinersRepository: NoticeToMarinersRepository,
        routeRepository: RouteRepository
    ) {
//        self.asamRepository = asamRepository
//        self.moduRepository = moduRepository
//        self.portRepository = portRepository
//        self.lightRepository = lightRepository
//        self.radioBeaconRepository = radioBeaconRepository
//        self.differentialGPSStationRepository = differentialGPSStationRepository
//        self.electronicPublicationRepository = electronicPublicationRepository
//        self.navigationalWarningRepository = navigationalWarningRepository
//        self.noticeToMarinersRepository = noticeToMarinersRepository
//        self.routeRepository = routeRepository

        asamInitializer = AsamInitializer(repository: asamRepository)
        moduInitializer = ModuInitializer(repository: moduRepository)
        portInitializer = PortInitializer(repository: portRepository)
        lightInitializer = LightInitializer(repository: lightRepository)
        radioBeaconInitializer = RadioBeaconInitializer(repository: radioBeaconRepository)
        differentialGPSStationInitializer = DifferentialGPSStationInitializer(
            repository: differentialGPSStationRepository
        )
        electronicPublicationInitializer = ElectronicPublicationInitializer(
            repository: electronicPublicationRepository
        )
        navigationalWarningInitializer = NavigationalWarningInitializer(
            repository: navigationalWarningRepository
        )
        noticeToMarinersInitializer = NoticeToMarinersInitializer(
            repository: noticeToMarinersRepository
        )
        registerBackgroundHandler()
    }
    // swiftlint:enable function_parameter_count

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
    var manager = ServerTrustManager(evaluators: ["msi.nga.mil": DefaultTrustEvaluator(validateHost: true)])
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
        asamInitializer?.registerBackgroundHandler()
        moduInitializer?.registerBackgroundHandler()
        portInitializer?.registerBackgroundHandler()
        lightInitializer?.registerBackgroundHandler()
        radioBeaconInitializer?.registerBackgroundHandler()
        differentialGPSStationInitializer?.registerBackgroundHandler()
        electronicPublicationInitializer?.registerBackgroundHandler()
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
            MSI.shared.loadAllData()
        default:
            break
        }
    }
    
    func scheduleAppRefresh() {
        asamInitializer?.scheduleRefresh()
        moduInitializer?.scheduleRefresh()
        portInitializer?.scheduleRefresh()
        lightInitializer?.scheduleRefresh()
        radioBeaconInitializer?.scheduleRefresh()
        differentialGPSStationInitializer?.scheduleRefresh()
        electronicPublicationInitializer?.scheduleRefresh()
        navigationalWarningInitializer?.scheduleRefresh()
        noticeToMarinersInitializer?.scheduleRefresh()
    }
    
    func loadAllData() {
        // if there was a previous load, and it was less than 5 minutes ago just chill
        if let loadAllDataTime = loadAllDataTime, loadAllDataTime.timeIntervalSince(Date()) < (5 * 60) {
            NSLog("Already loaded data within the last 5 minutes.  Let's not")
            return
        }
        loadAllDataTime = Date()
        NSLog("Load all data")
        
        asamInitializer?.fetch()
        moduInitializer?.fetch()
        portInitializer?.fetch()
        lightInitializer?.fetch()
        radioBeaconInitializer?.fetch()
        differentialGPSStationInitializer?.fetch()
        electronicPublicationInitializer?.fetch()
        navigationalWarningInitializer?.fetch()
        noticeToMarinersInitializer?.fetch()
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
                        self.loadAllData()
                    }
                }
            }
        }
    }
}
