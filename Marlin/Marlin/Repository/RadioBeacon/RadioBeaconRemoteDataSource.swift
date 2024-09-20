//
//  RadioBeaconRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct RadioBeaconRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: any RadioBeaconRemoteDataSource = RadioBeaconRemoteDataSourceImpl()
}

extension InjectedValues {
    var radioBeaconRemoteDataSource: any RadioBeaconRemoteDataSource {
        get { Self[RadioBeaconRemoteDataSourceProviderKey.self] }
        set { Self[RadioBeaconRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol RadioBeaconRemoteDataSource: RemoteDataSource {
    func fetch(
        noticeYear: String?,
        noticeWeek: String?
    ) async -> [RadioBeaconModel]
}

actor RadioBeaconRemoteDataSourceImpl: RadioBeaconRemoteDataSource {
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
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [RadioBeaconModel] {
        let operation = RadioBeaconDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(operation: operation)
    }
}
