//
//  DGPSStationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct DGPSStationRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: DGPSStationRemoteDataSource = DGPSStationRemoteDataSource()
}

extension InjectedValues {
    var dgpsemoteDataSource: DGPSStationRemoteDataSource {
        get { Self[DGPSStationRemoteDataSourceProviderKey.self] }
        set { Self[DGPSStationRemoteDataSourceProviderKey.self] = newValue }
    }
}

class DGPSStationRemoteDataSource: RemoteDataSource<DGPSStationModel> {
    init() {
        super.init(dataSource: DataSources.dgps)
    }

    func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DGPSStationModel] {
        let operation = DGPSStationDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
