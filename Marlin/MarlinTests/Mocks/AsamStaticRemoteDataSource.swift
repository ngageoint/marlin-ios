//
//  AsamStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/12/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor AsamStaticRemoteDataSource: AsamRemoteDataSource {
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
    
    var asamList: [AsamModel] = []
    
    func setList(_ list: [AsamModel]) {
        self.asamList = list
    }

    func fetch(dateString: String? = nil) async -> [AsamModel] {
        NSLog("Returning \(asamList.count) asams")
        return asamList
    }
}
