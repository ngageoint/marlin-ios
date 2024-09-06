//
//  AsamRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/23.
//

import Foundation
import UIKit
import BackgroundTasks

private struct AsamRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: AsamRemoteDataSource = AsamRemoteDataSource()
}

extension InjectedValues {
    var asamRemoteDataSource: AsamRemoteDataSource {
        get { Self[AsamRemoteDataSourceProviderKey.self] }
        set { Self[AsamRemoteDataSourceProviderKey.self] = newValue }
    }
}

class AsamRemoteDataSource: RemoteDataSource<AsamModel> {

    init() {
        super.init(dataSource: DataSources.asam)
    }

    func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [AsamModel] {
        let operation = AsamDataFetchOperation(dateString: dateString)
        return await fetch(task: task, operation: operation)
    }
}
