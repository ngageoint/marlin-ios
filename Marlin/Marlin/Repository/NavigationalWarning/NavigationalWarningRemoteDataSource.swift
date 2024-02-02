//
//  NavigationalWarningRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class NavigationalWarningRemoteDataSource: RemoteDataSource<NavigationalWarningModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.navWarning, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [NavigationalWarningModel] {
        let operation = NavigationalWarningDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }
}
