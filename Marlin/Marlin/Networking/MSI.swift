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
    
    var asamRepository: AsamRepository?
    var moduRepository: ModuRepository?
    var portRepository: PortRepository?
    var lightRepository: LightRepository?
    var radioBeaconRepository: RadioBeaconRepository?
    var differentialGPSStationRepository: DifferentialGPSStationRepository?
    var electronicPublicationRepository: ElectronicPublicationRepository?
    var navigationalWarningRepository: NavigationalWarningRepository?
    var noticeToMarinersRepository: NoticeToMarinersRepository?
    var routeRepository: RouteRepository?

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
        self.asamRepository = asamRepository
        self.moduRepository = moduRepository
        self.portRepository = portRepository
        self.lightRepository = lightRepository
        self.radioBeaconRepository = radioBeaconRepository
        self.differentialGPSStationRepository = differentialGPSStationRepository
        self.electronicPublicationRepository = electronicPublicationRepository
        self.navigationalWarningRepository = navigationalWarningRepository
        self.noticeToMarinersRepository = noticeToMarinersRepository
        self.routeRepository = routeRepository

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
    }
    // swiftlint:enable function_parameter_count

//    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
//    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
//    var cancellable = Set<AnyCancellable>()
    
    var loading: Bool {
        for dataSource in DataSourceDefinitions.allCases where self.appState.loadingDataSource[dataSource.definition.key] == true {
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
    
    lazy var capabilitiesSession: Session = {
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        let manager = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
//    let mainDataList: [any BatchImportable.Type] = [
//        Asam.self,
//        Modu.self,
//        NavigationalWarning.self,
//        Light.self,
//        Port.self,
//        RadioBeacon.self,
//        DifferentialGPSStation.self,
//        DFRS.self,
//        DFRSArea.self,
//        ElectronicPublication.self,
//        NoticeToMariners.self
//    ]

//    lazy var initialLoadQueue: OperationQueue = {
//        var queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.name = "Initial data load queue"
//        return queue
//    }()
    
//    lazy var dataFetchQueue: OperationQueue = {
//        var queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.name = "Data fetch queue"
//        return queue
//    }()
//    
//    lazy var backgroundFetchQueue: OperationQueue = {
//        var queue = OperationQueue()
//        queue.maxConcurrentOperationCount = 1
//        queue.name = "Background fetch queue"
//        return queue
//    }()
    
//    init() {
//        NotificationCenter.default.publisher(for: .DataSourceProcessed)
//            .receive(on: RunLoop.main)
//            .compactMap {
//                $0.object as? DataSourceUpdatedNotification
//            }
//            .sink { item in
//                let dataSource = self.mainDataList.first { type in
//                    item.key == type.key
//                }
//                switch dataSource {
//                case let mapImage as MapImage.Type:
//                    mapImage.imageCache.clearCache()
//                default:
//                    break
//                }
//            }
//            .store(in: &cancellable)
//    }
    
    func registerBackgroundHandler() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "mil.nga.msi.refresh", using: nil) { task in
//            MSI.shared.backgroundFetch(task: task)
//        }
        
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
    
//    func backgroundFetch(task: BGTask) {
//        print("background handler")
//        MSI.shared.scheduleAppRefresh()
//        
//        let allLoadList: [any BatchImportable.Type] = self.mainDataList.filter { importable in
//            let sync = importable.shouldSync()
//            return sync
//        }
//        
//        NSLog("Fetching new data from the API for \(allLoadList.count) data sources")
//        
//        if allLoadList.isEmpty {
//            task.setTaskCompleted(success: true)
//        }
//        
//        for importable in allLoadList {
//            NSLog("Fetching new data for \(importable.key)")
//            self.loadData(
//                type: importable.decodableRoot,
//                dataType: importable,
//                operationQueue: self.backgroundFetchQueue)
//        }
//        
//        var expired = false
//        task.expirationHandler = {
//            expired = true
//            self.backgroundFetchQueue.cancelAllOperations()
//        }
//        
//        self.backgroundFetchQueue.addBarrierBlock {
//            DispatchQueue.main.async {
//                task.setTaskCompleted(success: !expired)
//            }
//        }
//    }
    
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

//        let initialDataLoadList: [any BatchImportable.Type] = self.mainDataList.filter { importable in
//            if let dataSourceType = importable as? any DataSource.Type {
//                return UserDefaults.standard
//                    .dataSourceEnabled(dataSourceType.definition) &&
//                !self.isLoaded(type: importable) &&
//                !(importable.seedDataFiles ?? []).isEmpty
//            }
//            return false
//        }
//        if !initialDataLoadList.isEmpty {
//            
//            NSLog("Loading initial data from \(initialDataLoadList.count) data sources")
//            PersistenceController.current.addViewContextObserver(
//                self,
//                selector: #selector(self.managedObjectContextObjectChangedObserver(notification:)),
//                name: .NSManagedObjectContextObjectsDidChange)
//
//            for importable in initialDataLoadList {
//                self.loadInitialData(type: importable.decodableRoot, dataType: importable)
//            }
//
//        } else {
//            UserDefaults.standard.initialDataLoaded = true
//            
//            let allLoadList: [any BatchImportable.Type] = self.mainDataList.filter { importable in
//                let sync = importable.shouldSync()
//                return sync
//            }
//            
//            NSLog("Fetching new data from the API for \(allLoadList.count) data sources")
//            for importable in allLoadList {
//                NSLog("Fetching new data for \(importable.key)")
//                self.loadData(type: importable.decodableRoot, dataType: importable)
//            }
//        }
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
        
//    func loadInitialData<T: Decodable, D: NSManagedObject & BatchImportable>(
//        type: T.Type,
//        dataType: D.Type,
//        operationQueue: OperationQueue? = nil
//    ) {
//        let initialDataLoadOperation = DataLoadOperation(
//            appState: appState,
//            taskName: "Load Initial Data \(dataType.key)")
//        initialDataLoadOperation.action = { [weak initialDataLoadOperation] in
//            guard let initialDataLoadOperation = initialDataLoadOperation else {
//                return
//            }
//            initialDataLoadOperation.loadInitialData(type: type.self, dataType: dataType)
//        }
//        DispatchQueue.main.async {
//            self.appState.loadingDataSource[dataType.key] = true
//        }
//        (operationQueue ?? initialLoadQueue).addOperation(initialDataLoadOperation)
//    }
//    
//    func loadData<T: Decodable, D: NSManagedObject & BatchImportable>(
//        type: T.Type,
//        dataType: D.Type,
//        operationQueue: OperationQueue? = nil
//    ) {
//        if dataType.key == DataSources.asam.key || dataType.key == DataSources.modu.key {
//            return
//        }
//        
//        let dataLoadOperation = DataLoadOperation(appState: appState, taskName: "Load Data \(dataType.key)")
//        dataLoadOperation.action = { [weak dataLoadOperation] in
//            guard let dataLoadOperation = dataLoadOperation else {
//                return
//            }
//            dataLoadOperation.loadData(type: type.self, dataType: dataType)
//        }
//
//        DispatchQueue.main.async {
//            self.appState.loadingDataSource[dataType.key] = true
//        }
//        (operationQueue ?? dataFetchQueue).addOperation(dataLoadOperation)
//    }
    
//    func isLoaded<D: BatchImportable>(type: D.Type) -> Bool {
//        let count = try? PersistenceController.current.countOfObjects(D.self)
//        return (count ?? 0) > 0
//    }
}
