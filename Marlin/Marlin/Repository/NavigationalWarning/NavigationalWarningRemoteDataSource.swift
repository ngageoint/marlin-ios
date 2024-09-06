//
//  NavigationalWarningRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct NavigationalWarningRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: NavigationalWarningRemoteDataSource = NavigationalWarningRemoteDataSource()
}

extension InjectedValues {
    var navWarningRemoteDataSource: NavigationalWarningRemoteDataSource {
        get { Self[NavigationalWarningRemoteDataSourceProviderKey.self] }
        set { Self[NavigationalWarningRemoteDataSourceProviderKey.self] = newValue }
    }
}

class NavigationalWarningRemoteDataSource: RemoteDataSource<NavigationalWarningModel> {
    init() {
        super.init(dataSource: DataSources.navWarning)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [NavigationalWarningModel] {
        let operation = NavigationalWarningDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }
}
