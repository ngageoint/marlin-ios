//
//  NavigationWarningMap.swift
//  Marlin
//
//  Created by Daniel Barela on 5/1/23.
//

import Foundation
import MapKit
import CoreData
import Combine

class NavigationWarningMap: NSObject, MapMixin {
    var warning: NavigationalWarning?
    var mapState: MapState?
    var lastChange: Date?
    var mapShapes: [MKShape] = []
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var show: Bool = true
    var cancellable = Set<AnyCancellable>()
    
    override init() {
        
    }
    
    init(warning: NavigationalWarning) {
        self.warning = warning
    }
    
    func setupMixin(marlinMap: MarlinMap, mapView: MKMapView) {
        mapState = marlinMap.mapState
        if warning != nil {
            setupSingleNavigationalWarning(mapView: mapView)
        } else {
            setupAllNavigationalWarnings(mapView: mapView)
        }
    }
    
    func setupSingleNavigationalWarning(mapView: MKMapView) {
        if let mappedLocation = warning?.mappedLocation {
            for location in mappedLocation.locations {
                if let shape = location.mkShape {
                    mapShapes.append(shape)
                }
            }
        }
        
        for shape in mapShapes {
            print("Adding the shape: \(shape)")
            if let polygon = shape as? MKPolygon {
                mapView.addOverlay(polygon)
            } else if let polyline = shape as? MKPolyline {
                mapView.addOverlay(polyline)
            } else if let circle = shape as? MKCircle {
                mapView.addOverlay(circle)
            }  else {
                mapView.addAnnotation(shape)
            }
        }
    }
    
    func setupAllNavigationalWarnings(mapView: MKMapView) {
        NotificationCenter.default.publisher(for: .FocusNavigationalWarning)
            .compactMap {
                $0.object as? NavigationalWarning
            }
            .sink(receiveValue: { [weak self] in
                self?.focus(item: $0)
            })
            .store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .receive(on: RunLoop.main)
            .compactMap {
                $0.object as? DataSourceUpdatedNotification
            }
            .sink { item in
                if item.key == NavigationalWarning.key {
                    self.refresh()
                }
            }
            .store(in: &cancellable)
        
        userDefaultsShowPublisher?
            .removeDuplicates()
            .handleEvents(receiveOutput: { show in
                print("Show \(NavigationalWarning.self): \(show)")
            })
            .sink() { [weak self] show in
                self?.show = show
                self?.refresh()
            }
            .store(in: &cancellable)
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if lastChange == nil || lastChange != mapState.mixinStates["FetchRequestMixin\(NavigationalWarning.key)DateUpdated"] as? Date {
            lastChange = mapState.mixinStates["FetchRequestMixin\(NavigationalWarning.key)DataUpdated"] as? Date ?? Date()
            
            if mapState.mixinStates["FetchRequestMixin\(NavigationalWarning.key)DataUpdated"] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates["FetchRequestMixin\(NavigationalWarning.key)DataUpdated"] = self.lastChange
                }
            }
            
//            if let selfOverlay = self.overlay {
//                mapView.removeOverlay(selfOverlay)
//            }
//
            let newFetchRequest = self.getFetchRequest(show: self.show)
            let context = PersistenceController.current.newTaskContext()
            if let objects = try? context.fetch(newFetchRequest) {
                
                for warning in objects {
                    if let mappedLocation = warning.mappedLocation {
                        for location in mappedLocation.locations {
                            if let shape = location.mkShape {
                                mapShapes.append(shape)
                            }
                        }
                    }
                }
            }
            
            for shape in mapShapes {
                print("Adding the shape: \(shape)")
                if let polygon = shape as? MKPolygon {
                    mapView.addOverlay(polygon)
                } else if let polyline = shape as? MKPolyline {
                    mapView.addOverlay(polyline)
                } else if let circle = shape as? MKCircle {
                    mapView.addOverlay(circle)
                }  else {
                    mapView.addAnnotation(shape)
                }
            }
        }
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["FetchRequestMixin\(NavigationalWarning.key)DateUpdated"] = Date()
        }
    }
    
    func focus(item: NavigationalWarning) {
        DispatchQueue.main.async {
            self.mapState?.center = item.region
        }
    }
    
    func getFetchRequest(show: Bool) -> NSFetchRequest<NavigationalWarning> {
        let fetchRequest: NSFetchRequest<NavigationalWarning> = NavigationalWarning.fetchRequest()
        fetchRequest.sortDescriptors = NavigationalWarning.defaultSort.map({ parameter in
            parameter.toNSSortDescriptor()
        })
        var filterPredicates: [NSPredicate] = []
        if !show == true {
            filterPredicates.append(NSPredicate(value: false))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates)
        return fetchRequest
    }
}
