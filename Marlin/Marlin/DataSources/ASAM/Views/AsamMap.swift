//
//  AsamMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MapKit
import CoreData
import Combine

class AsamMap<T: MapImage>: FetchRequestMap<T> {
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, objects: objects, showAsTiles: showAsTiles)
        self.sortDescriptors = [NSSortDescriptor(keyPath: \Asam.date, ascending: true)]
        self.focusNotificationName = .FocusAsam
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapasam)
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: Asam.key)
    }

    override func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [any DataSource]? {
        return nil
    }

    override func itemKeys(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [String: [String]] {
        if mapView.zoomLevel < minZoom {
            return [:]
        }
        guard show == true else {
            return [:]
        }
        let screenPercentage = 0.03
        let tolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance

        guard let fetchRequest = self.getFetchRequest(show: self.show) else {
            return [:]
        }
        var predicates: [NSPredicate] = []
        if let predicate = fetchRequest.predicate {
            predicates.append(predicate)
        }

        predicates.append(getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon))

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        if let asams = try? PersistenceController.current.fetch(fetchRequest: fetchRequest) as? [any DataSource] {
            let asamKeys: [String] = asams.compactMap { asam in
                if let asam = asam as? Asam {
                    return asam.reference
                }
                return nil
            }
            return [DataSources.asam.key: asamKeys]
        }

        return [:]
    }

}
