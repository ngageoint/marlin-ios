//
//  AsamDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/7/23.
//

import Foundation
import CoreData

enum AsamDataLoadOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class AsamDataLoadOperation: Operation {
    
    var asams: [AsamModel] = []
    var localDataSource: AsamLocalDataSource
    var count: Int = 0
    
    init(asams: [AsamModel], localDataSource: AsamLocalDataSource) {
        self.asams = asams
        self.localDataSource = localDataSource
    }
    
    var state: AsamDataLoadOperationState = .isReady {
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
            await loadData()
            await self.finishLoad()
        }
    }
    
    @MainActor func finishLoad() {
        self.state = .isFinished
    }
    
    func loadData() async {
        if self.isCancelled {
            return
        }
                
        let asamPropertyContainer = AsamPropertyContainer(asams: asams)
        NSLog("Loading asams \(asamPropertyContainer.asam.count)")
        count = (try? await localDataSource.batchImport(from: asams)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: Asam.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: Asam.key)
                )
            }
        }
    }
}
