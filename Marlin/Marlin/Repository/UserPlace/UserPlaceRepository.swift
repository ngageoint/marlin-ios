//
//  UserPlaceRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 3/4/24.
//

import Foundation
import Combine

enum UserPlaceItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let userPlace):
            return userPlace.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ userPlace: UserPlaceModel)
    case sectionHeader(header: String)
}

class UserPlaceRepository: ObservableObject {
    var localDataSource: UserPlaceLocalDataSource

    init(localDataSource: UserPlaceLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func getUserPlace(uri: URL) async -> UserPlaceModel? {
        await localDataSource.getUserPlace(uri: uri)
    }
    func insert(userPlace: UserPlaceModel) async -> UserPlaceModel? {
        await localDataSource.insert(userPlace: userPlace)
    }

    func getUserPlacesInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) async -> [UserPlaceModel] {
        await localDataSource.getUserPlacesInBounds(
            filters: filters,
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude
        )
    }
    func getCount(filters: [DataSourceFilterParameter]?) async -> Int {
        await localDataSource.getCount(filters: filters)
    }
    func userPlaces(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[UserPlaceItem], Error> {
        localDataSource.userPlaces(filters: filters, paginatedBy: paginator)
    }
}
