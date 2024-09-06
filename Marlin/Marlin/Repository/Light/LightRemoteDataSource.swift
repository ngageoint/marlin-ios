//
//  LightRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct LightRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: LightRemoteDataSource = LightRemoteDataSource()
}

extension InjectedValues {
    var lightRemoteDataSource: LightRemoteDataSource {
        get { Self[LightRemoteDataSourceProviderKey.self] }
        set { Self[LightRemoteDataSourceProviderKey.self] = newValue }
    }
}

class LightRemoteDataSource: RemoteDataSource<LightModel> {
    init() {
        super.init(dataSource: DataSources.light)
    }

    func fetch(
        task: BGTask? = nil,
        volume: String,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [LightModel] {
        let operation = LightDataFetchOperation(volume: volume, noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
