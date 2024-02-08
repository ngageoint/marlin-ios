//
//  RadioBeaconInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/24.
//

import Foundation
import BackgroundTasks

class RadioBeaconInitializer: Initializer {
    let repository: RadioBeaconRepository

    init(repository: RadioBeaconRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.radioBeacon)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = RadioBeaconInitialDataLoadOperation(
                localDataSource: repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchRadioBeacons()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchRadioBeacons()
            }
        }
    }
}
