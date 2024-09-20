//
//  PortStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor PortStaticRemoteDataSource: PortRemoteDataSource {
    typealias DataModel = PortModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.port.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.port
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }
    
    var list: [PortModel] = []
    
    func setList(_ list: [PortModel]) {
        self.list = list
    }

    func fetch() async -> [PortModel] {
        list
    }
}
