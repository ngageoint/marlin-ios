//
//  LightRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct LightRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: LightRemoteDataSource = LightRemoteDataSource()
}

extension InjectedValues {
    var lightRemoteDataSource: LightRemoteDataSource {
        get { Self[LightRemoteDataSourceProviderKey.self] }
        set { Self[LightRemoteDataSourceProviderKey.self] = newValue }
    }
}

actor LightRemoteDataSource: RemoteDataSource {
    typealias DataModel = LightModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.light.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.light
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(
        task: BGTask? = nil,
        volume: String,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [LightModel] {
        let operation = LightDataFetchOperation(volume: volume, noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(operation: operation)
    }
}
