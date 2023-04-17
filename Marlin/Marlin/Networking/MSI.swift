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
import Combine
import SwiftUI
import BackgroundTasks

public class MSI {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
    var cancellable = Set<AnyCancellable>()
    
    var loading: Bool {
        for importable in self.masterDataList {
            if self.appState.loadingDataSource[importable.key] == true {
                return true
            }
        }
        return false
    }
    
    static let shared = MSI()
    let appState = AppState()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    var manager = ServerTrustManager(evaluators: ["msi.gs.mil": DisabledTrustEvaluator()
                                                           , "msi.om.east.paas.nga.mil": DisabledTrustEvaluator()])
    var loadAllDataTime: Date?
    lazy var session: Session = {
        
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    lazy var capabilitiesSession: Session = {
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        let m = ServerTrustManager(allHostsMustBeEvaluated: false, evaluators: [:])
        return Session(configuration: configuration, serverTrustManager: m)
    }()
    
    let masterDataList: [any BatchImportable.Type] = [Asam.self, Modu.self, NavigationalWarning.self, Light.self, Port.self, RadioBeacon.self, DifferentialGPSStation.self, DFRS.self, DFRSArea.self, ElectronicPublication.self, NoticeToMariners.self]
    
    lazy var initialLoadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Initial data load queue"
        return queue
    }()
    
    lazy var dataFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Data fetch queue"
        return queue
    }()
    
    lazy var backgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Background fetch queue"
        return queue
    }()
    
    init() {
        NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .receive(on: RunLoop.main)
            .compactMap {
                $0.object as? DataSourceUpdatedNotification
            }
            .sink { item in
                let dataSource = self.masterDataList.first { type in
                    item.key == type.key
                }
                
                dataSource?.postProcess()
            }
            .store(in: &cancellable)
    }
    
    func registerBackgroundHandler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "mil.nga.msi.refresh", using: nil) { task in
            MSI.shared.backgroundFetch(task: task)
        }
    }
    
    func backgroundFetch(task: BGTask) {
        print("background handler")
        MSI.shared.scheduleAppRefresh()
        
        let allLoadList: [any BatchImportable.Type] = self.masterDataList.filter { importable in
            let sync = importable.shouldSync()
            return sync
        }
        
        NSLog("Fetching new data from the API for \(allLoadList.count) data sources")
        
        if allLoadList.isEmpty {
            task.setTaskCompleted(success: true)
        }
        
        for importable in allLoadList {
            NSLog("Fetching new data for \(importable.key)")
            self.loadData(type: importable.decodableRoot, dataType: importable, operationQueue: self.backgroundFetchQueue)
        }
        
        var expired = false
        task.expirationHandler = {
            expired = true
            self.backgroundFetchQueue.cancelAllOperations()
        }
        
        self.backgroundFetchQueue.addBarrierBlock {
            DispatchQueue.main.async {
                task.setTaskCompleted(success: !expired)
            }
        }
    }
    
    func onChangeOfScenePhase(_ newPhase: ScenePhase) {
        switch newPhase {
        case .background:
            // this will ensure these notifications are not sent since the user should have seen them
            appState.dataSourceBatchImportNotificationsPending = [:]
            scheduleAppRefresh()
        case .active:
            MSI.shared.loadAllData()
        default:
            break
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "mil.nga.msi.refresh")
        // Fetch no earlier than 1 hour from now
        request.earliestBeginDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch BGTaskScheduler.Error.notPermitted {
            print("BGTaskScheduler.shared.submit notPermitted")
        } catch BGTaskScheduler.Error.tooManyPendingTaskRequests {
            print("BGTaskScheduler.shared.submit tooManyPendingTaskRequests")
        } catch BGTaskScheduler.Error.unavailable {
            print("BGTaskScheduler.shared.submit unavailable")
        } catch {
            print("BGTaskScheduler.shared.submit \(error.localizedDescription)")
        }
        print("Background task scheduled")
    }
    
    func loadAllData() {
        // if there was a previous load, and it was less than 5 minutes ago just chill
        if let loadAllDataTime = loadAllDataTime, loadAllDataTime.timeIntervalSince(Date()) < (5 * 60) {
            NSLog("Already loaded data within the last 5 minutes.  Let's not")
            return
        }
        loadAllDataTime = Date()
        NSLog("Load all data")
        
        let initialDataLoadList: [any BatchImportable.Type] = self.masterDataList.filter { importable in
            if let ds = importable as? any DataSource.Type {
                return UserDefaults.standard.dataSourceEnabled(ds) && !self.isLoaded(type: importable) && !(importable.seedDataFiles ?? []).isEmpty
            }
            return false
        }
        
        if !initialDataLoadList.isEmpty {
            
            NSLog("Loading initial data from \(initialDataLoadList.count) data sources")
            PersistenceController.current.addViewContextObserver(self, selector: #selector(self.managedObjectContextObjectChangedObserver(notification:)), name: .NSManagedObjectContextObjectsDidChange)
            
            for importable in initialDataLoadList {
                self.loadInitialData(type: importable.decodableRoot, dataType: importable)
            }

        } else {
            UserDefaults.standard.initialDataLoaded = true
            
            let allLoadList: [any BatchImportable.Type] = self.masterDataList.filter { importable in
                let sync = importable.shouldSync()
                return sync
            }
            
            NSLog("Fetching new data from the API for \(allLoadList.count) data sources")
            for importable in allLoadList {
                NSLog("Fetching new data for \(importable.key)")
                self.loadData(type: importable.decodableRoot, dataType: importable)
            }
        }
    }
    
    @objc func managedObjectContextObjectChangedObserver(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            if let dataSourceItem = inserts.first as? (any DataSource) {
                var allLoaded = true
                for (dataSource, loading) in self.appState.loadingDataSource {
                    if loading && type(of: dataSourceItem).key != dataSource {
                        allLoaded = false
                    }
                }
                if allLoaded {
                    PersistenceController.current.removeViewContextObserver(self, name: .NSManagedObjectContextObjectsDidChange)
                }
                DispatchQueue.main.async {
                    self.appState.loadingDataSource[type(of: dataSourceItem).key] = false
                    
                    if allLoaded {
                        UserDefaults.standard.initialDataLoaded = true
                        self.loadAllDataTime = nil
                        self.loadAllData()
                    }
                }
            }
        }
    }
        
    func loadInitialData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type, operationQueue: OperationQueue? = nil) {
        let initialDataLoadOperation = DataLoadOperation(appState: appState, taskName: "Load Initial Data \(dataType.key)")
        initialDataLoadOperation.action = { [weak initialDataLoadOperation] in
            guard let initialDataLoadOperation = initialDataLoadOperation else {
                return
            }
            initialDataLoadOperation.loadInitialData(type: type.self, dataType: dataType)
        }
        DispatchQueue.main.async {
            self.appState.loadingDataSource[dataType.key] = true
        }
        (operationQueue ?? initialLoadQueue).addOperation(initialDataLoadOperation)
    }
    
    func loadData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type, operationQueue: OperationQueue? = nil) {
        let dataLoadOperation = DataLoadOperation(appState: appState, taskName: "Load Data \(dataType.key)")
        dataLoadOperation.action = { [weak dataLoadOperation] in
            guard let dataLoadOperation = dataLoadOperation else {
                return
            }
            dataLoadOperation.loadData(type: type.self, dataType: dataType)
        }
        DispatchQueue.main.async {
            self.appState.loadingDataSource[dataType.key] = true
        }
        (operationQueue ?? dataFetchQueue).addOperation(dataLoadOperation)
    }
    
    func isLoaded<D: BatchImportable>(type: D.Type) -> Bool {
        let count = try? PersistenceController.current.countOfObjects(D.self)
        return (count ?? 0) > 0
    }
}

