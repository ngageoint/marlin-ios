//
//  RouteRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/9/23.
//

import Foundation
import CoreData
import Combine

enum RouteItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let route):
            return route.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ route: RouteModel)
    case sectionHeader(header: String)
}

class RouteRepository: ObservableObject {
    var localDataSource: RouteLocalDataSource
    init(localDataSource: RouteLocalDataSource) {
        self.localDataSource = localDataSource
    }

    func routes(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[RouteItem], Error> {
        localDataSource.routes(filters: filters, paginatedBy: paginator)
    }

    func observeRouteListItems() -> AnyPublisher<CollectionDifference<RouteModel>, Never> {
        localDataSource.observeRouteListItems()
    }
    
    func getRoute(routeURI: URL?) -> RouteModel? {
        localDataSource.getRoute(routeURI: routeURI)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        localDataSource.getCount(filters: filters)
    }
    
    func deleteRoute(route: URL) {
        localDataSource.deleteRoute(route: route)
    }

    func getRoutes(filters: [DataSourceFilterParameter]?) async -> [RouteModel] {
        await localDataSource.getRoutes(filters: filters)
    }
}
