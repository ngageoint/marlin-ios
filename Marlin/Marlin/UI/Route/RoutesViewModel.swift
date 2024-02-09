//
//  RoutesViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 10/9/23.
//

import Foundation
import Combine

class RoutesViewModel: ObservableObject {
    @Published var routes: [RouteModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()
    
    var repository: RouteRepository?
    
    var publisher: AnyPublisher<CollectionDifference<RouteModel>, Never>?
    
    func fetchRoutes() {
        NSLog("Fetch the routes")
        if publisher != nil {
            return
        }
        self.publisher = repository?.observeRouteListItems()
        
        if let publisher = publisher {
            $routes.applyingChanges(publisher) { route in
                self.loaded = true
                NSLog("Route")
                return route
            }
            .sink(receiveCompletion: { completion in
                NSLog("Completion \(completion)")
            }, receiveValue: { value in
                NSLog("value \(value)")
                self.loaded = true
                self.routes = value
            })
            .store(in: &disposables)
        }
    }
    
    func deleteRoute(route: URL?) {
        if let url = route {
            repository?.deleteRoute(route: url)
        }
    }
}
