//
//  AsamInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation

enum AsamInitialDataLoadOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class AsamInitialDataLoadOperation: Operation {
    var count: Int = 0
    var localDataSource: AsamLocalDataSource
    
    init(localDataSource: AsamLocalDataSource) {
        self.localDataSource = localDataSource
    }
    
    var state: AsamInitialDataLoadOperationState = .isReady {
        willSet(newValue) {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isExecuting: Bool { state == .isExecuting }
    override var isFinished: Bool {
        if isCancelled && state != .isExecuting { return true }
        return state == .isFinished
    }
    override var isAsynchronous: Bool { true }
    
    override func start() {
        guard !isCancelled else { return }
        state = .isExecuting
        Task {
            await self.startLoad()
            await loadData()
            await self.finishLoad()
        }
    }
    
    @MainActor func startLoad() {
        MSI.shared.appState.loadingDataSource[Asam.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: Asam.self))
    }
    
    @MainActor func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[Asam.key] = false
        NotificationCenter.default.post(name: .DataSourceLoaded, object: DataSourceItem(dataSource: Asam.self))
        NotificationCenter.default.post(name: .DataSourceNeedsProcessed, object: DataSourceUpdatedNotification(key: Asam.key))
        NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: Asam.key))
    }
    
    func loadData() async {
        NSLog("ASAM Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = Bundle.main.url(forResource: "asam", withExtension: "json") {
                do {
                    let data = try Data(contentsOf: url)
                    let decoder = JSONDecoder()
                    let asamPropertyContainer = try decoder.decode(AsamPropertyContainer.self, from: data)
                    count = await localDataSource.insert(task: nil, asams: asamPropertyContainer.asam)
                } catch {
                    print("error:\(error)")
                }
            }
        
    }
}
