//
//  RadioBeaconStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor RadioBeaconStaticRemoteDataSource: RadioBeaconRemoteDataSource {
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
    
    var list: [RadioBeaconModel] = []
    
    func setList(list: [RadioBeaconModel]) async {
        self.list = list
    }

    func fetch(noticeYear: String? = nil, noticeWeek: String? = nil) async -> [RadioBeaconModel] {
        list
    }
}
