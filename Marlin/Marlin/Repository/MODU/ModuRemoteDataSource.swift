//
//  ModuRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import UIKit
import BackgroundTasks

private struct ModuRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: ModuRemoteDataSource = ModuRemoteDataSource()
}

extension InjectedValues {
    var moduRemoteDataSource: ModuRemoteDataSource {
        get { Self[ModuRemoteDataSourceProviderKey.self] }
        set { Self[ModuRemoteDataSourceProviderKey.self] = newValue }
    }
}

actor ModuRemoteDataSource: RemoteDataSource {
    typealias DataModel = ModuModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.modu.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.modu
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [ModuModel] {
        let operation = ModuDataFetchOperation(dateString: dateString)
        return await fetch(operation: operation)
    }
}
