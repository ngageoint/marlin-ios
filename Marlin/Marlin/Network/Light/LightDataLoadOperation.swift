//
//  LightDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Kingfisher

class LightDataLoadOperation: CountingDataLoadOperation {

    var lights: [LightModel] = []
    var localDataSource: LightLocalDataSource

    init(lights: [LightModel], localDataSource: LightLocalDataSource) {
        self.lights = lights
        self.localDataSource = localDataSource
    }

    @MainActor override func finishLoad() {
        if count != 0 {
            Task {
                await localDataSource.postProcess()

                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.light.key)
                )
            }
        }
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.light.key] = false
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: lights)) ?? 0
    }
}
