//
//  DifferentialGPSStationStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor DifferentialGPSStationStaticRemoteDataSource: DGPSStationRemoteDataSource {
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
    
    var list: [DGPSStationModel] = []
    
    func setList(_ list: [DGPSStationModel]) {
        self.list = list
    }

    func fetch(
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DGPSStationModel] {
        NSLog("Returning \(list.count) dgps")
        return list
    }
}
