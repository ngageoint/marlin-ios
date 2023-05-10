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
import sf_wkt_ios

class NavigationalWarningMap: NSObject, MapMixin {
    var warning: NavigationalWarning?
    var mapState: MapState?
    var lastChange: Date?
    var mapOverlays: [MKOverlay] = []
    var mapAnnotations: [MKAnnotation] = []
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
    var show: Bool = true
    var cancellable = Set<AnyCancellable>()
    
    static let MIXIN_STATE_KEY = "FetchRequestMixin\(NavigationalWarning.key)DateUpdated"
    
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
        if let locations = warning?.locations {
            for location in locations {
                if let wkt = location["wkt"] {
                    var distance: Double?
                    if let distanceString = location["distance"] {
                        distance = Double(distanceString)
                    }
                    if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                        if let shape = shape as? MKOverlay {
                            mapOverlays.append(shape)
                        } else {
                            mapAnnotations.append(shape)
                        }
                    }
                }
            }
        }
        
        mapView.addOverlays(mapOverlays)
        mapView.addAnnotations(mapAnnotations)
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
        if warning == nil && (lastChange == nil || (lastChange != mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date && mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] != nil)) {
            lastChange = mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date ?? Date()
            
            if mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date == nil {
                DispatchQueue.main.async {
                    mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] = self.lastChange
                }
            }
            
            mapView.removeOverlays(mapOverlays)
            mapView.removeAnnotations(mapAnnotations)
            
            let newFetchRequest = self.getFetchRequest(show: self.show)
            let context = PersistenceController.current.newTaskContext()
            context.performAndWait {
                if let objects = try? context.fetch(newFetchRequest) {
                    
                    for warning in objects {
                        if let locations = warning.locations {
                            for location in locations {
                                if let wkt = location["wkt"] {
                                    var distance: Double?
                                    if let distanceString = location["distance"] {
                                        distance = Double(distanceString)
                                    }
                                    if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                                        if let shape = shape as? MKOverlay {
                                            self.mapOverlays.append(shape)
                                        } else {
                                            self.mapAnnotations.append(shape)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            mapView.addOverlays(self.mapOverlays)
            mapView.addAnnotations(self.mapAnnotations)
        }
    }
    
    func refresh() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] = Date()
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
