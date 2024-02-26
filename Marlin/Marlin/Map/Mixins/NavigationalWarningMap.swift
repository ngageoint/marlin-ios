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

class NavigationalWarningPolygon: MKPolygon {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningPolyline: MKPolyline {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningGeodesicPolyline: MKGeodesicPolyline {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningAnnotation: MKPointAnnotation {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningCircle: MKCircle {
    var warning: NavigationalWarningModel?
}

class NavigationalWarningMap: DataSourceMap {

    override var minZoom: Int {
        get {
            return 2
        }
        set {

        }
    }

    override init(repository: TileRepository? = nil, mapFeatureRepository: MapFeatureRepository? = nil) {
        super.init(repository: repository, mapFeatureRepository: mapFeatureRepository)

        orderPublisher = UserDefaults.standard.orderPublisher(key: DataSources.navWarning.key)
        userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapnavWarning)
    }

    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: NavigationalWarning.key)
    }

    override func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
        if annotation is NavigationalWarningAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: NavigationalWarning.key,
                for: annotation)
            if let systemImageName = DataSources.navWarning.systemImageName {
                let radius = CGFloat(2) / 3.0 * UIScreen.main.scale * DataSources.navWarning.imageScale
                if let image = CircleImage(color: DataSources.navWarning.color, radius: radius, fill: true) {
                    if let dataSourceImage = DataSources.navWarning.image?.aspectResize(
                        to: CGSize(
                            width: image.size.width / 1.5,
                            height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate)
                        .maskWithColor(color: UIColor.white) {
                        let combinedImage: UIImage? = UIImage.combineCentered(image1: image, image2: dataSourceImage)
                        annotationView.image = combinedImage ?? UIImage(systemName: systemImageName)
                    }
                }
            }
            return annotationView
        }
        return nil
    }

    override func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
        if let polygon = overlay as? NavigationalWarningPolygon {
            let renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.3)
            return renderer
        } else if let polyline = overlay as? NavigationalWarningGeodesicPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            return renderer
        } else if let polyline = overlay as? NavigationalWarningPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = NavigationalWarning.color
            renderer.lineWidth = 3
            return renderer
        } else if let circle = overlay as? NavigationalWarningCircle {
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = NavigationalWarning.color
            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.2)
            renderer.lineWidth = 3
            return renderer
        }
        return nil
    }

    override func itemKeys(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        touchPoint: CGPoint
    ) async -> [String: [String]] {
        if await mapView.zoomLevel < minZoom {
            return [:]
        }
        guard show == true else {
            return [:]
        }
        let screenPercentage = 0.03
        let tolerance = await mapView.region.span.longitudeDelta * Double(screenPercentage)
        let minLon = location.longitude - tolerance
        let maxLon = location.longitude + tolerance
        let minLat = location.latitude - tolerance
        let maxLat = location.latitude + tolerance

        let distanceTolerance = await mapView.visibleMapRect.size.width * Double(screenPercentage)

        return [
            dataSourceKey: await mapFeatureRepository?.getItemKeys(
                minLatitude: minLat,
                maxLatitude: maxLat,
                minLongitude: minLon,
                maxLongitude: maxLon,
                distanceTolerance: distanceTolerance
            ) ?? []
        ]
    }
}

class NavigationalWarningFetchMap<T: NavigationalWarning & MapImage>: FetchRequestMap<T> {
    override public init(fetchPredicate: NSPredicate? = nil, objects: [T]? = nil, showAsTiles: Bool = true) {
        super.init(fetchPredicate: fetchPredicate, objects: objects, showAsTiles: showAsTiles)
        self.sortDescriptors = NavigationalWarning.defaultSort.map({ parameter in
            parameter.toNSSortDescriptor()
        })
        self.focusNotificationName = .FocusNavigationalWarning
        self.userDefaultsShowPublisher = UserDefaults.standard.publisher(for: \.showOnMapnavWarning)
    }
    
    override func setupMixin(mapState: MapState, mapView: MKMapView) {
        super.setupMixin(mapState: mapState, mapView: mapView)
        mapView.register(ImageAnnotationView.self, forAnnotationViewWithReuseIdentifier: NavigationalWarning.key)
    }
    
    override func focus(item: T) {
        DispatchQueue.main.async {
            self.mapState?.center = MKCoordinateRegion(
                center: item.coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
        }
    }
    
    override func items(
        at location: CLLocationCoordinate2D,
        mapView: MKMapView,
        touchPoint: CGPoint
    ) -> [any DataSource]? {
        return nil
//        if mapView.zoomLevel < minZoom {
//            return nil
//        }
//        guard show == true else {
//            return nil
//        }
//        let screenPercentage = 0.03
//        let distanceTolerance = mapView.visibleMapRect.size.width * Double(screenPercentage)
//        let longitudeTolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
//        let minLon = location.longitude - longitudeTolerance
//        let maxLon = location.longitude + longitudeTolerance
//        let minLat = location.latitude - longitudeTolerance
//        let maxLat = location.latitude + longitudeTolerance
//        guard let fetchRequest = self.getFetchRequest(show: self.show) else {
//            return nil
//        }
//        var predicates: [NSPredicate] = []
//        if let predicate = fetchRequest.predicate {
//            predicates.append(predicate)
//        }
//        
//        predicates.append(getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon))
//        
//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        
//        var matched: [NavigationalWarning] = []
//        if let navWarnings = try? PersistenceController.current.fetch(
//            fetchRequest: fetchRequest) as? [NavigationalWarning] {
//            // verify the actual shapes match and not just the bounding box
//            for warning in navWarnings where verifyMatch(
//                    warning: warning,
//                    location: location,
//                    longitudeTolerance: longitudeTolerance,
//                    distanceTolerance: distanceTolerance
//                ) {
//                    matched.append(warning)
//            }
//        }
//        
//        return matched
    }
    
    func verifyMatch(
        warning: NavigationalWarning,
        location: CLLocationCoordinate2D,
        longitudeTolerance: Double,
        distanceTolerance: Double
    ) -> Bool {
        if let locations = warning.locations {
            for wktLocation in locations {
                if let wkt = wktLocation["wkt"] {
                    var distance: Double?
                    if let distanceString = wktLocation["distance"] {
                        distance = Double(distanceString)
                    }
                    if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
                        if let polygon = shape as? MKPolygon {
                            for polyline in polygon.getGeodesicClickAreas() 
                            where polygonHitTest(closedPolyline: polyline, location: location) {
                                return true
                            }
                        } else if let polyline = shape as? MKPolyline {
                            if lineHitTest(line: polyline, location: location, distanceTolerance: distanceTolerance) {
                                return true
                            }
                        } else if let point = shape as? MKPointAnnotation {
                            let minLon = location.longitude - longitudeTolerance
                            let maxLon = location.longitude + longitudeTolerance
                            let minLat = location.latitude - longitudeTolerance
                            let maxLat = location.latitude + longitudeTolerance
                            if minLon <= point.coordinate.longitude 
                                && maxLon >= point.coordinate.longitude
                                && minLat <= point.coordinate.latitude
                                && maxLat >= point.coordinate.latitude {
                                return true
                            }
                        } else if let circle = shape as? MKCircle {
                            if circleHitTest(circle: circle, location: location) {
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
}

// class NavigationalWarningMap2: NSObject, MapMixin {
//    var uuid: UUID = UUID()
//    var localDataSource: NavigationalWarningLocalDataSource?
//    var mapState: MapState?
//    var lastChange: Date?
//    var mapOverlays: [MKOverlay] = []
//    var mapAnnotations: [MKAnnotation] = []
//    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Bool>?
//    var show: Bool = true
//    var cancellable = Set<AnyCancellable>()
//    var zoomOnFocus: Bool = false
//    var setup: Bool = false
//    
//    static let MIXIN_STATE_KEY = "FetchRequestMixin\(NavigationalWarning.key)DateUpdated"
//    
//    init(zoomOnFocus: Bool = false) {
//        super.init()
//        self.zoomOnFocus = zoomOnFocus
//    }
//    
//    init(localDataSource: NavigationalWarningLocalDataSource, zoomOnFocus: Bool = false) {
//        super.init()
//        self.localDataSource = localDataSource
//        self.zoomOnFocus = zoomOnFocus
//    }
//    
//    func setupMixin(mapState: MapState, mapView: MKMapView) {
//        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: NavigationalWarning.key)
//        self.mapState = mapState
////        if warning != nil {
////            setupSingleNavigationalWarning(mapView: mapView)
////        }
//
//        NotificationCenter.default.publisher(for: .DataSourceUpdated)
//            .receive(on: RunLoop.main)
//            .compactMap {
//                $0.object as? DataSourceUpdatedNotification
//            }
//            .sink { item in
//                if item.key == NavigationalWarning.key {
//                    self.refresh()
//                }
//            }
//            .store(in: &cancellable)
//
//        userDefaultsShowPublisher?
//            .removeDuplicates()
//            .handleEvents(receiveOutput: { show in
//                print("Show \(NavigationalWarning.self): \(show)")
//            })
//            .sink { [weak self] show in
//                self?.show = show
//                self?.refresh()
//            }
//            .store(in: &cancellable)
//    }
//    
//    func addWarning(warning: NavigationalWarningModel, location: [String: String]) {
//        if let wkt = location["wkt"] {
//            var distance: Double?
//            if let distanceString = location["distance"] {
//                distance = Double(distanceString)
//            }
//            if let shape = MKShape.fromWKT(wkt: wkt, distance: distance) {
//                if let polygon = shape as? MKPolygon {
//                    let navPoly = NavigationalWarningPolygon(points: polygon.points(), count: polygon.pointCount)
//                    navPoly.warning = warning
//                    mapOverlays.append(navPoly)
//                } else if let polyline = shape as? MKGeodesicPolyline {
//                    let navline = NavigationalWarningGeodesicPolyline(
//                        points: polyline.points(),
//                        count: polyline.pointCount
//                    )
//                    navline.warning = warning
//                    mapOverlays.append(navline)
//                } else if let polyline = shape as? MKPolyline {
//                    let navline = NavigationalWarningPolyline(points: polyline.points(), count: polyline.pointCount)
//                    navline.warning = warning
//                    mapOverlays.append(navline)
//                } else if let point = shape as? MKPointAnnotation {
//                    let navpoint = NavigationalWarningAnnotation()
//                    navpoint.coordinate = point.coordinate
//                    navpoint.warning = warning
//                    mapAnnotations.append(navpoint)
//                } else if let circle = shape as? MKCircle {
//                    let navcircle = NavigationalWarningCircle(center: circle.coordinate, radius: circle.radius)
//                    navcircle.warning = warning
//                    mapOverlays.append(navcircle)
//                }
//            }
//        }
//    }
//    
////    func setupSingleNavigationalWarning(mapView: MKMapView) {
////        if let warning = warning, let locations = warning.locations {
////            for location in locations {
////                addWarning(warning: warning, location: location)
////            }
////        }
////        
////        mapView.addOverlays(mapOverlays)
////        mapView.addAnnotations(mapAnnotations)
////    }
//    
//    func updateMixin(mapView: MKMapView, mapState: MapState) {
//        if lastChange == nil
//                || (lastChange != mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date
//                    && mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] != nil) {
//            lastChange = mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date ?? Date()
//            
//            if mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] as? Date == nil {
//                DispatchQueue.main.async {
//                    mapState.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] = self.lastChange
//                }
//            }
//            
//            mapView.removeOverlays(mapOverlays)
//            mapView.removeAnnotations(mapAnnotations)
//            
//            let newFetchRequest = self.getFetchRequest(show: self.show)
//            let context = PersistenceController.current.newTaskContext()
//            context.performAndWait {
//                if let objects = try? context.fetch(newFetchRequest) {
//                    
//                    for warning in objects {
//                        if let locations = warning.locations {
//                            for location in locations {
//                                addWarning(warning: warning, location: location)
//                            }
//                        }
//                    }
//                }
//            }
//            mapView.addOverlays(self.mapOverlays)
//            mapView.addAnnotations(self.mapAnnotations)
//        }
//    }
//    
//    func removeMixin(mapView: MKMapView, mapState: MapState) {
//        mapView.removeOverlays(mapOverlays)
//        mapView.removeAnnotations(mapAnnotations)
//    }
//    
//    func refresh() {
//        DispatchQueue.main.async {
//            self.mapState?.mixinStates[NavigationalWarningMap.MIXIN_STATE_KEY] = Date()
//        }
//    }
//    
//    func getFetchRequest(show: Bool) -> NSFetchRequest<NavigationalWarning> {
//        let fetchRequest: NSFetchRequest<NavigationalWarning> = NavigationalWarning.fetchRequest()
//        fetchRequest.sortDescriptors = NavigationalWarning.defaultSort.map({ parameter in
//            parameter.toNSSortDescriptor()
//        })
//        var filterPredicates: [NSPredicate] = []
//        if !show == true {
//            filterPredicates.append(NSPredicate(value: false))
//        }
//        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: filterPredicates)
//        return fetchRequest
//    }
//    
//    func viewForAnnotation(annotation: MKAnnotation, mapView: MKMapView) -> MKAnnotationView? {
//        if annotation is NavigationalWarningAnnotation {
//            let annotationView = mapView.dequeueReusableAnnotationView(
//                withIdentifier: NavigationalWarning.key,
//                for: annotation)
//            if let systemImageName = NavigationalWarning.systemImageName, 
//                let annotation = annotation as? NavigationalWarningAnnotation,
//                let warning = annotation.warning {
//                let images = warning.mapImage(marker: false, zoomLevel: 2, tileBounds3857: nil)
//                var combinedImage: UIImage? = UIImage.combineCentered(image1: images.first, image2: nil)
//                if !images.isEmpty {
//                    for image in images.dropFirst() {
//                        combinedImage = UIImage.combineCentered(image1: combinedImage, image2: image)
//                    }
//                }
//                annotationView.image = combinedImage ?? UIImage(systemName: systemImageName)
//            }
//            return annotationView
//        }
//        return nil
//    }
//
//    func items(at location: CLLocationCoordinate2D, mapView: MKMapView, touchPoint: CGPoint) -> [DataSource]? {
//        return []
////        let screenPercentage = 0.03
////        let tolerance = mapView.visibleMapRect.size.width * Double(screenPercentage)
////        
////        var items: Set<NavigationalWarning> = Set<NavigationalWarning>()
////        
////        for overlay in mapOverlays {
////            if let overlay = overlay as? NavigationalWarningPolyline {
////                if lineHitTest(line: overlay, location: location, distanceTolerance: tolerance),
////                   let warning = overlay.warning {
////                    PersistenceController.current.viewContext.performAndWait {
////                        if let thing = PersistenceController.current.viewContext.object(
////                            with: warning.objectID) as? NavigationalWarning {
////                            items.insert(thing)
////                        }
////                    }
////                }
////            } else if let overlay = overlay as? NavigationalWarningPolygon {
////                if polygonHitTest(polygon: overlay, location: location), let warning = overlay.warning {
////                    PersistenceController.current.viewContext.performAndWait {
////                        if let thing = PersistenceController.current.viewContext.object(
////                            with: warning.objectID) as? NavigationalWarning {
////                            items.insert(thing)
////                        }
////                    }
////                }
////            } else if let overlay = overlay as? NavigationalWarningCircle {
////                if circleHitTest(circle: overlay, location: location), let warning = overlay.warning {
////                    PersistenceController.current.viewContext.performAndWait {
////                        if let thing = PersistenceController.current.viewContext.object(
////                            with: warning.objectID) as? NavigationalWarning {
////                            items.insert(thing)
////                        }
////                    }
////                }
////            }
////        }
////        
////        // find the points
////        let longitudeTolerance = mapView.region.span.longitudeDelta * Double(screenPercentage)
////        let minLon = location.longitude - longitudeTolerance
////        let maxLon = location.longitude + longitudeTolerance
////        let minLat = location.latitude - longitudeTolerance
////        let maxLat = location.latitude + longitudeTolerance
////
////        let fetchRequest = self.getFetchRequest(show: self.show)
////
////        var predicates: [NSPredicate] = []
////        if let predicate = fetchRequest.predicate {
////            predicates.append(predicate)
////        }
////
////        predicates.append(getBoundingPredicate(minLat: minLat, maxLat: maxLat, minLon: minLon, maxLon: maxLon))
////
////        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
////
////        if let points = try? PersistenceController.current.fetch(fetchRequest: fetchRequest) {
////            for point in points {
////                items.insert(point)
////            }
////        }
////        
////        return Array(items)
//    }
//    
//    func getBoundingPredicate(minLat: Double, maxLat: Double, minLon: Double, maxLon: Double) -> NSPredicate {
//        return NSPredicate(
//            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
//            minLat, maxLat, minLon, maxLon
//        )
//    }
//    
//    func renderer(overlay: MKOverlay) -> MKOverlayRenderer? {
//        if let polygon = overlay as? NavigationalWarningPolygon {
//            let renderer = MKPolygonRenderer(polygon: polygon)
//            renderer.strokeColor = NavigationalWarning.color
//            renderer.lineWidth = 3
//            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.3)
//            return renderer
//        } else if let polyline = overlay as? NavigationalWarningGeodesicPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.strokeColor = NavigationalWarning.color
//            renderer.lineWidth = 3
//            return renderer
//        } else if let polyline = overlay as? NavigationalWarningPolyline {
//            let renderer = MKPolylineRenderer(polyline: polyline)
//            renderer.strokeColor = NavigationalWarning.color
//            renderer.lineWidth = 3
//            return renderer
//        } else if let circle = overlay as? NavigationalWarningCircle {
//            let renderer = MKCircleRenderer(circle: circle)
//            renderer.strokeColor = NavigationalWarning.color
//            renderer.fillColor = NavigationalWarning.color.withAlphaComponent(0.2)
//            renderer.lineWidth = 3
//            return renderer
//        }
//        return nil
//    }
// }
