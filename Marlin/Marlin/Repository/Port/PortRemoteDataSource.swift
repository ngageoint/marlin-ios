//
//  PortRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import UIKit
import BackgroundTasks

private struct PortRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: PortRemoteDataSource = PortRemoteDataSource()
}

extension InjectedValues {
    var portRemoteDataSource: PortRemoteDataSource {
        get { Self[PortRemoteDataSourceProviderKey.self] }
        set { Self[PortRemoteDataSourceProviderKey.self] = newValue }
    }
}

actor PortRemoteDataSource: RemoteDataSource {
    typealias DataModel = PortModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.port.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.port
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [PortModel] {
        let operation = PortDataFetchOperation()
        return await fetch(operation: operation)
    }
}
