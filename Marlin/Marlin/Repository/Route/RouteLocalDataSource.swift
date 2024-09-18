//
//  RouteLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import CoreData
import Combine
import UIKit

struct RouteModelPage {
    var routeList: [RouteItem]
    var next: Int?
    var currentHeader: String?
}

protocol RouteLocalDataSource {
    @discardableResult
    func getRoute(routeURI: URL?) -> RouteModel?
    func getRoutesInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [RouteModel]
    func routes(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[RouteItem], Error>
    func getRoutes(
        filters: [DataSourceFilterParameter]?
    ) async -> [RouteModel]
    func observeRouteListItems() -> AnyPublisher<CollectionDifference<RouteModel>, Never>

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func deleteRoute(route: URL)
}

class RouteCoreDataDataSource: CoreDataDataSource, RouteLocalDataSource, ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()
    
    func getRoute(routeURI: URL?) -> RouteModel? {
        if let routeURI = routeURI,
            let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: routeURI),
           let route = try? self.context.existingObject(with: id) as? Route {
            return RouteModel(route: route)
        }
        return nil
    }
    
    func getRoutesInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [RouteModel] {
        var routes: [RouteModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = Route.fetchRequest()
            var predicates: [NSPredicate] = buildPredicates(filters: filters)

            if let minLatitude = minLatitude,
               let maxLatitude = maxLatitude,
               let minLongitude = minLongitude,
               let maxLongitude = maxLongitude {
                predicates.append(boundsPredicate(
                    minLatitude: minLatitude,
                    maxLatitude: maxLatitude,
                    minLongitude: minLongitude,
                    maxLongitude: maxLongitude
                ))
            }

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.route.key).toNSSortDescriptors()
            routes = (context.fetch(request: fetchRequest)?.map { route in
                RouteModel(route: route)
            }) ?? []
        }

        return routes
    }

    func boundsPredicate(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> NSPredicate {
        return NSPredicate(
            format: """
            (maxLatitude >= %lf AND minLatitude <= %lf AND maxLongitude >= %lf AND minLongitude <= %lf) \
            OR minLongitude < -180 OR maxLongitude > 180
            """, minLatitude, maxLatitude, minLongitude, maxLongitude
        )
    }

    func observeRouteListItems() -> AnyPublisher<CollectionDifference<RouteModel>, Never> {
        let request = Route.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedTime", ascending: false)]
        return context.changesPublisher(for: request, transformer: { route in
            RouteModel(route: route)
        })
        .receive(on: DispatchQueue.main)
        .catch { _ in Empty() }
        .eraseToAnyPublisher()
    }

    func routes(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[RouteItem], Error> {
        return routes(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.routeList)
            .eraseToAnyPublisher()
    }

    func routes(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<RouteModelPage, Error> {

        let request = Route.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.route.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.route.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })
        var previousHeader: String? = currentHeader
        var routes: [RouteItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                routes = fetched.flatMap { route in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [RouteItem.listItem(RouteModel(route: route))]
                    }

                    if !sortDescriptor.section {
                        return [RouteItem.listItem(RouteModel(route: route))]
                    }

                    return createSectionHeaderAndListItem(
                        route: route,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let routePage: RouteModelPage = RouteModelPage(
            routeList: routes, next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(routePage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        route: Route,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [RouteItem] {
        let currentValue = route.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    RouteItem.sectionHeader(header: sortValueString),
                    RouteItem.listItem(RouteModel(route: route))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                RouteItem.sectionHeader(header: sortValueString),
                RouteItem.listItem(RouteModel(route: route))
            ]
        }

        return [RouteItem.listItem(RouteModel(route: route))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.asam.dateFormatter.string(from: currentValue)
            }
        case .int:
            sortValueString = (sortValue as? Int)?.zeroIsEmptyString
        case .float:
            sortValueString = (sortValue as? Float)?.zeroIsEmptyString
        case .double:
            sortValueString = (sortValue as? Double)?.zeroIsEmptyString
        case .boolean:
            sortValueString = ((sortValue as? Bool) ?? false) ? "True" : "False"
        case .enumeration:
            sortValueString = sortValue as? String
        case .latitude:
            sortValueString = (sortValue as? Double)?.latitudeDisplay
        case .longitude:
            sortValueString = (sortValue as? Double)?.longitudeDisplay
        default:
            return nil
        }
        return sortValueString
    }

    func routes(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<RouteModelPage, Error> {
        return routes(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<RouteModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.routes(
                        filters: filters,
                        at: next,
                        currentHeader: result.currentHeader,
                        paginatedBy: paginator
                    )
                    .wait(untilOutputFrom: paginator)
                    .retry(.max)
                    .prepend(result)
                    .eraseToAnyPublisher()
                } else {
                    return Just(result)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func getRoutes(filters: [DataSourceFilterParameter]?) async -> [RouteModel] {
        return await context.perform {
            let fetchRequest = Route.fetchRequest()
            let predicates: [NSPredicate] = self.buildPredicates(filters: filters)

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.route.key).toNSSortDescriptors()
            return (self.context.fetch(request: fetchRequest)?.map { route in
                RouteModel(route: route)
            }) ?? []
        }
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = Route.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.route.key).toNSSortDescriptors()
        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func deleteRoute(route: URL) {
        context.perform {
            if let id = self.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: route),
                let route = try? self.context.existingObject(with: id) as? Route {
                self.context.delete(route)
                try? self.context.save()
            }
        }
    }

}
