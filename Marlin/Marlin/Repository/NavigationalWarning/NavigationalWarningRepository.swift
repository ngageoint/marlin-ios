//
//  NavigationalWarningRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/27/23.
//

import Foundation
import CoreData

enum NavigationalWarningItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let navigationalWarning):
            return navigationalWarning.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ navigationalWarning: NavigationalWarningModel)
    case sectionHeader(header: String)
}

class NavigationalWarningRepository: ObservableObject {
    var localDataSource: NavigationalWarningLocalDataSource
    private var remoteDataSource: NavigationalWarningRemoteDataSource
    init(localDataSource: NavigationalWarningLocalDataSource, remoteDataSource: NavigationalWarningRemoteDataSource) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }

    func createOperation() -> NavigationalWarningDataFetchOperation {
        return NavigationalWarningDataFetchOperation()
    }

    func getNavigationalWarning(msgYear: Int64, msgNumber: Int64, navArea: String?) -> NavigationalWarningModel? {
        localDataSource.getNavigationalWarning(msgYear: msgYear, msgNumber: msgNumber, navArea: navArea)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }

    func getNavigationalWarnings(
        filters: [DataSourceFilterParameter]?
    ) async -> [NavigationalWarningModel] {
        await localDataSource.getNavigationalWarnings(filters: filters)
    }
}
