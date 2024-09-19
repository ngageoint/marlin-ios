//
//  AsamRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/23.
//

import Foundation
import UIKit
import BackgroundTasks

private struct AsamRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: AsamRemoteDataSource = AsamRemoteDataSource()
}

extension InjectedValues {
    var asamRemoteDataSource: AsamRemoteDataSource {
        get { Self[AsamRemoteDataSourceProviderKey.self] }
        set { Self[AsamRemoteDataSourceProviderKey.self] = newValue }
    }
}

actor AsamRemoteDataSource: RemoteDataSource, Sendable {
    typealias DataModel = AsamModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.asam.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.asam
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(dateString: String? = nil) async -> [AsamModel] {
        let operation = AsamDataFetchOperation(dateString: dateString)
        return await fetch(operation: operation)
    }
}
