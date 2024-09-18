//
//  RadioBeaconRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct RadioBeaconRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: RadioBeaconRemoteDataSource = RadioBeaconRemoteDataSource()
}

extension InjectedValues {
    var radioBeaconRemoteDataSource: RadioBeaconRemoteDataSource {
        get { Self[RadioBeaconRemoteDataSourceProviderKey.self] }
        set { Self[RadioBeaconRemoteDataSourceProviderKey.self] = newValue }
    }
}

class RadioBeaconRemoteDataSource: RemoteDataSource {
    typealias DataModel = RadioBeaconModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.radioBeacon.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.radioBeacon
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [RadioBeaconModel] {
        let operation = RadioBeaconDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(operation: operation)
    }
}
