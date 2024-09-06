//
//  RadioBeaconRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

private struct RadioBeaconRemoteDataSourceProviderKey: InjectionKey {
    static var currentValue: RadioBeaconRemoteDataSource = RadioBeaconRemoteDataSource()
}

extension InjectedValues {
    var radioBeaconRemoteDataSource: RadioBeaconRemoteDataSource {
        get { Self[RadioBeaconRemoteDataSourceProviderKey.self] }
        set { Self[RadioBeaconRemoteDataSourceProviderKey.self] = newValue }
    }
}

class RadioBeaconRemoteDataSource: RemoteDataSource<RadioBeaconModel> {
    init() {
        super.init(dataSource: DataSources.radioBeacon)
    }

    func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [RadioBeaconModel] {
        let operation = RadioBeaconDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
