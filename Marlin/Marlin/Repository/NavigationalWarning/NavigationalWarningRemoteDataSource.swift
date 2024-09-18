//
//  NavigationalWarningRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct NavigationalWarningRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: NavigationalWarningRemoteDataSource = NavigationalWarningRemoteDataSource()
}

extension InjectedValues {
    var navWarningRemoteDataSource: NavigationalWarningRemoteDataSource {
        get { Self[NavigationalWarningRemoteDataSourceProviderKey.self] }
        set { Self[NavigationalWarningRemoteDataSourceProviderKey.self] = newValue }
    }
}

class NavigationalWarningRemoteDataSource: RemoteDataSource {
    typealias DataModel = NavigationalWarningModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.navWarning.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.navWarning
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [NavigationalWarningModel] {
        let operation = NavigationalWarningDataFetchOperation()
        return await fetch(operation: operation)
    }
}
