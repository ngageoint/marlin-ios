//
//  RemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import UIKit
import BackgroundTasks

protocol RemoteDataSource<DataModel>: Actor {
    associatedtype DataModel
    
    func dataSource() -> any DataSourceDefinition
    func backgroundFetchQueue() -> OperationQueue
    @discardableResult
    func fetch(operation: DataFetchOperation<DataModel>) async -> [DataModel]
}

extension RemoteDataSource {

    @discardableResult
    func fetch(operation: DataFetchOperation<DataModel>) async -> [DataModel] {
        NSLog("Start the operation to fetch new data \(operation)")
        // Start the operation.
        self.backgroundFetchQueue().addOperation(operation)

        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation.completionBlock = {
                Task {
                    continuation.resume(returning: operation.data)
                }
            }
        }
    }
}
