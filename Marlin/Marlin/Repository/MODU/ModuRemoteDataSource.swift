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
    static var currentValue: any ModuRemoteDataSource = ModuRemoteDataSourceImpl()
}

extension InjectedValues {
    var moduRemoteDataSource: any ModuRemoteDataSource {
        get { Self[ModuRemoteDataSourceProviderKey.self] }
        set { Self[ModuRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol ModuRemoteDataSource: RemoteDataSource {
    func fetch(dateString: String?) async -> [ModuModel]
}

actor ModuRemoteDataSourceImpl: ModuRemoteDataSource {
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

    func fetch(dateString: String? = nil) async -> [ModuModel] {
        let operation = ModuDataFetchOperation(dateString: dateString)
        return await fetch(operation: operation)
    }
}
