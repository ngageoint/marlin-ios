//
//  ModuStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

actor ModuStaticRemoteDataSource: ModuRemoteDataSource {
    typealias DataModel = ModuModel
    
    let _backgroundFetchQueue: OperationQueue
    
    init() {
        self._backgroundFetchQueue = OperationQueue()
        self._backgroundFetchQueue.maxConcurrentOperationCount = 1
        self._backgroundFetchQueue.name = "\(DataSources.modu.name) fetch queue"
    }
    
    func dataSource() -> any DataSourceDefinition {
        DataSources.modu
    }
    
    func backgroundFetchQueue() -> OperationQueue {
        _backgroundFetchQueue
    }
    
    var list: [ModuModel] = []
    
    func setList(_ list: [ModuModel]) {
        self.list = list
    }

    func fetch(dateString: String? = nil) async -> [ModuModel] {
        return list
    }
}
