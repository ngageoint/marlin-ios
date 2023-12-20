//
//  RouteRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 10/9/23.
//

import Foundation
import CoreData
import Combine

protocol RouteRepository {
    @discardableResult
    func getRoute(routeURI: URL?) -> RouteModel?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func observeRouteListItems() -> AnyPublisher<CollectionDifference<RouteModel>, Never>
    func deleteRoute(route: URL)
}

class RouteCoreDataRepository: RouteRepository, ObservableObject {
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
    
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getRoute(routeURI: URL?) -> RouteModel? {
        if let routeURI = routeURI, 
            let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: routeURI),
            let route = try? self.context.existingObject(with: id) as? Route {
            return RouteModel(route: route)
        }
        return nil
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = RouteFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0    }
    
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

class RouteRepositoryManager: RouteRepository, ObservableObject {
    func getRoute(routeURI: URL?) -> RouteModel? {
        repository.getRoute(routeURI: routeURI)
    }
    
    func observeRouteListItems() -> AnyPublisher<CollectionDifference<RouteModel>, Never> {
        repository.observeRouteListItems()
    }
    
    func deleteRoute(route: URL) {
        repository.deleteRoute(route: route)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
    
    private var repository: RouteRepository
    init(repository: RouteRepository) {
        self.repository = repository
    }
}
