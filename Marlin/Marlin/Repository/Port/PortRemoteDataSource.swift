//
//  PortRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import UIKit
import BackgroundTasks

private struct PortRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: PortRemoteDataSource = PortRemoteDataSource()
}

extension InjectedValues {
    var portRemoteDataSource: PortRemoteDataSource {
        get { Self[PortRemoteDataSourceProviderKey.self] }
        set { Self[PortRemoteDataSourceProviderKey.self] = newValue }
    }
}

class PortRemoteDataSource: RemoteDataSource<PortModel> {
    init() {
        super.init(dataSource: DataSources.port)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [PortModel] {
        let operation = PortDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }
}
