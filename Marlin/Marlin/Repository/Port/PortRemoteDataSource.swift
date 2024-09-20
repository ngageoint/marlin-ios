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
    static var currentValue: any PortRemoteDataSource = PortRemoteDataSourceImpl()
}

extension InjectedValues {
    var portRemoteDataSource: any PortRemoteDataSource {
        get { Self[PortRemoteDataSourceProviderKey.self] }
        set { Self[PortRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol PortRemoteDataSource: RemoteDataSource {
    func fetch() async -> [PortModel]
}

actor PortRemoteDataSourceImpl: PortRemoteDataSource {
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

    func fetch() async -> [PortModel] {
        let operation = PortDataFetchOperation()
        return await fetch(operation: operation)
    }
}
