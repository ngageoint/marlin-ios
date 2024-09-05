//
//  PortRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import UIKit
import BackgroundTasks

class PortRemoteDataSource: RemoteDataSource<PortModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.port, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [PortModel] {
        let operation = PortDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }
}
