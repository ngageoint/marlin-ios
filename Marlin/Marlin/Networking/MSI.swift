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

public class MSI {
    
    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
    let persistenceController = PersistenceController.shared

    static let shared = MSI()
    let appState = AppState()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    lazy var session: Session = {
        let manager = ServerTrustManager(evaluators: ["msi.gs.mil": DisabledTrustEvaluator()])
        configuration.httpMaximumConnectionsPerHost = 4
        configuration.timeoutIntervalForRequest = 120
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    let masterDataList: [BatchImportable.Type] = [Asam.self, Modu.self, NavigationalWarning.self, Light.self, Port.self, RadioBeacon.self, DifferentialGPSStation.self, DFRS.self, DFRSArea.self]
    
    
    func loadAllData() {
        NSLog("Load all data")
        var initialDataLoadList: [BatchImportable.Type] = []
        // if we think we need to load the initial data
        if !UserDefaults.standard.initialDataLoaded {
            initialDataLoadList = masterDataList.filter { importable in
                UserDefaults.standard.dataSourceEnabled(importable) && !isLoaded(type: importable) && !(importable.seedDataFiles ?? []).isEmpty
            }
        }

        if !initialDataLoadList.isEmpty {
            NSLog("Loading initial data from \(initialDataLoadList.count) data sources")
            NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectChangedObserver(notification:)), name: .NSManagedObjectContextObjectsDidChange, object: PersistenceController.shared.container.viewContext)

            DispatchQueue.main.async {
                for importable in initialDataLoadList {
                    self.appState.loadingDataSource[importable.key] = true
                }
                let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
                queue.async( execute:{
                    for importable in initialDataLoadList {
                        self.loadInitialData(type: importable.decodableRoot, dataType: importable)
                    }
                })
            }
        } else {
            let allLoadList: [BatchImportable.Type] = masterDataList.filter { importable in
                importable.shouldSync()
            }

            NSLog("Fetching new data from the API for \(allLoadList.count) data sources")
            for importable in allLoadList {
                self.loadData(type: importable.decodableRoot, dataType: importable)
            }
        }
    }
    
    actor Counter {
        var value = 0

        func increment() -> Int {
            value += 1
            return value
        }
        
        func increase() -> Int {
            return self.increment()
        }
    }
    
    @objc func managedObjectContextObjectChangedObserver(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            if let dataSourceItem = inserts.first as? DataSource {
                var allLoaded = true
                for (dataSource, loading) in self.appState.loadingDataSource {
                    if loading && type(of: dataSourceItem).key != dataSource {
                        allLoaded = false
                    }
                }
                if allLoaded {
                    NotificationCenter.default.removeObserver(self, name: .NSManagedObjectContextObjectsDidChange, object: PersistenceController.shared.container.viewContext)
                }
                DispatchQueue.main.async {
                    self.appState.loadingDataSource[type(of: dataSourceItem).key] = false
                    
                    if allLoaded {
                        UserDefaults.standard.initialDataLoaded = true
                        self.loadAllData()
                    }
                }
            }
        }
    }
    
    var loadCounters: [String: Counter] = [:]
    
    func loadInitialData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type) {
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        if let seedDataFiles = D.seedDataFiles {
            NSLog("Loading initial data for \(D.key)")
            for seedDataFile in seedDataFiles {
                if let localUrl = Bundle.main.url(forResource: seedDataFile, withExtension: "json") {
                    session.request(localUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: .none)
                        .responseDecodable(of: T.self, queue: queue) { response in
                            queue.async( execute:{
                                Task.detached {
                                    try await D.batchImport(value: response.value)
                                }
                            })
                        }
                }
            }
            return
        }
    }
    
    func loadData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type) {
        DispatchQueue.main.async {
            self.appState.loadingDataSource[D.key] = true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        let queryCounter = Counter()
        let requests = D.dataRequest()

        for request in requests {
            session.request(request)
                .validate()
                .responseDecodable(of: T.self, queue: queue) { response in
                    queue.async( execute:{
                        Task.detached {
                            try await D.batchImport(value: response.value)
                            
                            let sum = await queryCounter.increment()
                            NSLog("Queried for \(sum) of \(requests.count) for \(dataType.key)")
                            if sum == requests.count {
                                DispatchQueue.main.async {
                                    self.appState.loadingDataSource[D.key] = false
                                    UserDefaults.standard.updateLastSyncTimeSeconds(D.self)
                                }
                            }
                        }
                    })
                }
        }
    }
    
    func isLoaded<D: BatchImportable>(type: D.Type) -> Bool {
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(D.self)
        return (count ?? 0) > 0
    }
}

