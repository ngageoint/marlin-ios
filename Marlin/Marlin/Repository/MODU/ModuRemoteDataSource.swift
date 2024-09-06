//
//  ModuRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import UIKit
import BackgroundTasks

private struct ModuRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: ModuRemoteDataSource = ModuRemoteDataSource()
}

extension InjectedValues {
    var moduRemoteDataSource: ModuRemoteDataSource {
        get { Self[ModuRemoteDataSourceProviderKey.self] }
        set { Self[ModuRemoteDataSourceProviderKey.self] = newValue }
    }
}

class ModuRemoteDataSource: RemoteDataSource<ModuModel> {
    init() {
        super.init(dataSource: DataSources.modu)
    }

    func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [ModuModel] {
        let operation = ModuDataFetchOperation(dateString: dateString)
        return await fetch(task: task, operation: operation)
    }
}
