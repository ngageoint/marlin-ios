//
//  AsamRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/15/23.
//

import Foundation
import Combine

class AsamRepository: ObservableObject {
    private var localDataSource: AsamLocalDataSource
    init(localDataSource: AsamLocalDataSource) {
        self.localDataSource = localDataSource
    }
    func getAsam(reference: String?) -> AsamModel? {
        localDataSource.getAsam(reference: reference)
    }
    func getAsams(filters: [DataSourceFilterParameter]?) -> [AsamModel] {
        localDataSource.getAsams(filters: filters)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }
    func observeAsamListItems(filters: [DataSourceFilterParameter]?) -> AnyPublisher<CollectionDifference<AsamModel>, Never> {
        localDataSource.observeAsamListItems(filters: filters)
    }
}
