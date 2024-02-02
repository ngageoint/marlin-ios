//
//  DifferentialGPSStationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

// class DifferentialGPSStationInitializer: Initializer {
//    let repository: DifferentialGPSStationRepository
//
//    init(repository: DifferentialGPSStationRepository) {
//        self.repository = repository
//        super.init(dataSource: DataSources.dgps)
//    }
//
//    override func createOperation() -> Operation {
//        DifferentialGPSStationDataFetchOperation()
//    }
//
//    override func fetch() {
//        if repository.getCount(filters: nil) == 0 {
//            let initialDataLoadOperation = DifferentialGPSStationInitialDataLoadOperation(
//                localDataSource: self.repository.localDataSource
//            )
//            initialDataLoadOperation.completionBlock = {
//                Task {
//                    await self.repository.fetchAsams()
//                }
//            }
//
//            backgroundFetchQueue.addOperation(initialDataLoadOperation)
//        } else {
//            Task {
//                await self.repository.fetchAsams()
//            }
//        }
//    }
// }
