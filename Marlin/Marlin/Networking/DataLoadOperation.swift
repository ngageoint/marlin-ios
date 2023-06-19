//
//  DataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/23.
//

import Foundation
import UIKit
import BackgroundTasks
import CoreData
import Alamofire

class DataLoadOperation: Operation {
    actor Counter {
        var value = 0
        var total = 0
        
        func addToTotal(count: Int) -> Int {
            total += count
            return total
        }
        
        func increment() -> Int {
            value += 1
            return value
        }
        
        func increase() -> Int {
            return self.increment()
        }
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var action : (() -> ())?
    var cleanup : (() -> ())?
    
    let appState: AppState
    let taskName: String?
    
    init(appState: AppState, taskName: String?) {
        self.appState = appState
        self.taskName = taskName
    }

    override func main() {
        guard !self.isCancelled else {
            print("cancelled")
            return
        }
        assert(!Thread.isMainThread)
        registerBackgroundTask()
        guard backgroundTask != .invalid else { return }
        action?()
    }
    func doOnMainQueueAndBlockUntilFinished(_ f:@escaping ()->()) {
        OperationQueue.main.addOperations([BlockOperation(block: f)], waitUntilFinished: true)
    }
    
    func registerBackgroundTask() {
        NSLog("Register the background task \(self.name ?? "")")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            NSLog("iOS has signaled time has expired \(self?.name ?? "")")
            self?.cleanup?()
            print("canceling \(self?.name ?? "")")
            self?.cancel()
            print("calling endBackgroundTask \(self?.name ?? "")")
            self?.endBackgroundTaskIfActive()
        }
    }
    
    func endBackgroundTaskIfActive() {
        let isBackgroundTaskActive = backgroundTask != .invalid
        if isBackgroundTaskActive {
            NSLog("Background task ended. \(self.name ?? "")")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    func loadInitialData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type) {
        if self.isCancelled {
            return
        }
        DispatchQueue.main.async {
            self.appState.loadingDataSource[D.key] = true
            if let dataSource = dataType as? any DataSource.Type {
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: dataSource))
            }
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        if let seedDataFiles = D.seedDataFiles {
            NSLog("Loading initial data for \(D.key)")
            for seedDataFile in seedDataFiles {
                if let localUrl = Bundle.main.url(forResource: seedDataFile, withExtension: "json") {
                    _ = MSI.shared.session.request(localUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: .none)
                        .responseDecodable(of: T.self, queue: queue) { response in
                            if self.isCancelled {
                                return
                            }
                            queue.async( execute:{
                                Task.detached {
                                    try await D.batchImport(value: response.value, initialLoad: true)
                                    self.doOnMainQueueAndBlockUntilFinished {
                                        self.appState.loadingDataSource[D.key] = false
                                        self.endBackgroundTaskIfActive()
                                        if let dataSource = dataType as? any DataSource.Type {
                                            NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: dataSource))
                                            NotificationCenter.default.post(name: .DataSourceNeedsProcessed, object: DataSourceUpdatedNotification(key: dataSource.key))
                                            NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: dataSource.key))
                                        }
                                    }
                                }
                            })
                        }
                }
            }
            return
        }
    }
    
    func loadData<T: Decodable, D: NSManagedObject & BatchImportable>(type: T.Type, dataType: D.Type) {
        if self.isCancelled {
            return
        }
        DispatchQueue.main.async {
            self.appState.loadingDataSource[D.key] = true
            if let dataSource = dataType as? any DataSource.Type {
                NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: dataSource))
            }
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        let queryCounter = Counter()
        let requests = D.dataRequest()
        
        for request in requests {
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: T.self, queue: queue) { response in
                    if self.isCancelled {
                        return
                    }
                    queue.async(execute:{
                        
                        Task.detached {
                            let count = try await D.batchImport(value: response.value, initialLoad: false)
                            
                            if count != -1 {
                                let sum = await queryCounter.increment()
                                let totalCount = await queryCounter.addToTotal(count: count)
                                NSLog("Queried for \(sum) of \(requests.count) for \(dataType.key)")
                                if sum == requests.count {
                                    self.doOnMainQueueAndBlockUntilFinished {
                                        self.appState.loadingDataSource[D.key] = false
                                        self.endBackgroundTaskIfActive()
                                        UserDefaults.standard.updateLastSyncTimeSeconds(D.self)
                                        if let dataSource = dataType as? any DataSource.Type {
                                            NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: dataSource))
                                            if totalCount != 0 {
                                                NotificationCenter.default.post(name: .DataSourceNeedsProcessed, object: DataSourceUpdatedNotification(key: dataSource.key))
                                                NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: dataSource.key))
                                            }
                                        }
                                    }
                                }
                            } else {
                                if self.isCancelled {
                                    return
                                }
                                // need to requery
                                print("Requerying")
                                if let requeryRequest = D.getRequeryRequest(initialRequest: request) {
                                    MSI.shared.session.request(requeryRequest)
                                        .validate()
                                        .responseDecodable(of: T.self, queue: queue) { response in
                                            if self.isCancelled {
                                                return
                                            }
                                            queue.async(execute:{
                                                Task.detached {
                                                    let count = try await D.batchImport(value: response.value, initialLoad: true)
                                                    let sum = await queryCounter.increment()
                                                    let totalCount = await queryCounter.addToTotal(count: count)
                                                    NSLog("Queried for \(sum) of \(requests.count) for \(dataType.key)")
                                                    if sum == requests.count {
                                                        self.doOnMainQueueAndBlockUntilFinished {
                                                            self.appState.loadingDataSource[D.key] = false
                                                            self.endBackgroundTaskIfActive()
                                                            UserDefaults.standard.updateLastSyncTimeSeconds(D.self)
                                                            if let dataSource = dataType as? any DataSource.Type {
                                                                NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: dataSource))
                                                                if totalCount != 0 {
                                                                    NotificationCenter.default.post(name: .DataSourceNeedsProcessed, object: DataSourceUpdatedNotification(key: dataSource.key))
                                                                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: dataSource.key))
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            })
                                        }
                                }
                            }
                        }
                    })
                }
        }
    }
}
