//
//  RadioBeaconInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/24.
//

import Foundation
import BackgroundTasks

class RadioBeaconInitializer: Initializer {
    @Injected(\.radioBeaconRepository)
    private var repository: RadioBeaconRepository

    init() {
        super.init(dataSource: DataSources.radioBeacon)
    }

    override func createOperation() async -> Operation {
        repository.createOperation()
    }

    override func fetch() async {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = RadioBeaconInitialDataLoadOperation()
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
