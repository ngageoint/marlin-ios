//
//  DGPSStationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct DGPSStationRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: any DGPSStationRemoteDataSource = DGPSStationRemoteDataSourceImpl()
}

extension InjectedValues {
    var dgpsemoteDataSource: any DGPSStationRemoteDataSource {
        get { Self[DGPSStationRemoteDataSourceProviderKey.self] }
        set { Self[DGPSStationRemoteDataSourceProviderKey.self] = newValue }
    }
}

protocol DGPSStationRemoteDataSource: RemoteDataSource {
    func fetch(
        noticeYear: String?,
        noticeWeek: String?
    ) async -> [DGPSStationModel]
}

actor DGPSStationRemoteDataSourceImpl: DGPSStationRemoteDataSource {
    typealias DataModel = DGPSStationModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.dgps.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.dgps
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }

    func fetch(
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DGPSStationModel] {
        let operation = DGPSStationDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(operation: operation)
    }
}
