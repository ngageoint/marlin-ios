//
//  LightStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor LightStaticRemoteDataSource: LightRemoteDataSource {
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
    
    var list: [String: [LightModel]] = [:]
    
    func setList(_ list: [String: [LightModel]]) {
        self.list = list
    }

    func fetch(volume: String, noticeYear: String? = nil, noticeWeek: String? = nil) async -> [LightModel] {
        NSLog("Returning \(list[volume]?.count) lights")
        return list[volume] ?? []
    }
}
