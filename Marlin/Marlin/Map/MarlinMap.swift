//
//  MarlinMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import UIKit
import SwiftUI
import MapKit
import Combine
import CoreData
import gars_ios
import mgrs_ios

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

class MapSingleTap: UITapGestureRecognizer {
    var mapView: MKMapView?
    var coordinator: MapCoordinator
        
    init(coordinator: MapCoordinator, mapView: MKMapView) {
        self.mapView = mapView
        self.coordinator = coordinator
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    @objc private func execute() {
        coordinator.singleTapGesture(tapGestureRecognizer: self)
    }
}

class MapLongPress: UILongPressGestureRecognizer {
    var mapView: MKMapView?
    var coordinator: MapCoordinator
    
    init(coordinator: MapCoordinator, mapView: MKMapView) {
        self.mapView = mapView
        self.coordinator = coordinator
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
        self.delegate = self
    }
    
    @objc private func execute() {
        coordinator.longPressGesture(longPressGestureRecognizer: self)
    }
}

extension MapLongPress: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class MapState: ObservableObject, Hashable {
    static func == (lhs: MapState, rhs: MapState) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id = UUID()
    
    @Published var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    var centerDate: Date?
    @Published var center: MKCoordinateRegion? {
        didSet {
            centerDate = Date()
        }
    }
    @Published var forceCenter: MKCoordinateRegion? {
        didSet {
            forceCenterDate = Date()
        }
    }
    var forceCenterDate: Date?
    
    @Published var coordinateCenter: CLLocationCoordinate2D? {
        didSet {
            forceCenterDate = Date()
        }
    }
    
    @Published var searchResults: [MKMapItem]?
    
    @AppStorage("mapType") var mapType: Int = Int(MKMapType.standard.rawValue)
    @AppStorage("showGARS") var showGARS: Bool = false
    @AppStorage("showMGRS") var showMGRS: Bool = false
    @AppStorage("showMapScale") var showMapScale = false
    
    @Published var mixinStates: [String: Any] = [:]
}

class MainMapMixins: MapMixins {
    var subscriptions = Set<AnyCancellable>()
    var navigationalWarningMap = NavigationalWarningFetchMap()
        
    override init() {
        super.init()
        var mixins: [any MapMixin] = [PersistedMapState(), SearchResultsMap(), UserLayersMap()]
        
        if UserDefaults.standard.dataSourceEnabled(DifferentialGPSStation.definition) {
            mixins.append(DifferentialGPSStationMap<DifferentialGPSStation>(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(DFRS.definition) {
            mixins.append(DFRSMap<DFRS>(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(Light.definition) {
            mixins.append(LightMap<Light>(showAsTiles: true))
        }
        if UserDefaults.standard.dataSourceEnabled(RadioBeacon.definition) {
            mixins.append(RadioBeaconMap<RadioBeacon>(showAsTiles: true))
        }
        mixins.append(NavigationalWarningFetchMap())
        self.mixins = mixins
    }
    
    func addRouteMixin(routeRepository: (any RouteRepository)) {
        self.mixins.append(AllRoutesMixin(repository: routeRepository))
    }

    func addAsamTileRepository(tileRepository: TileRepository) {
        if UserDefaults.standard.dataSourceEnabled(DataSources.asam) {
            mixins.append(AsamMap(repository: tileRepository))
        }
    }

    func addModuTileRepository(tileRepository: TileRepository) {
        if UserDefaults.standard.dataSourceEnabled(DataSources.modu) {
            mixins.append(ModuMap(repository: tileRepository))
        }
    }

    func addPortTileRepository(tileRepository: TileRepository) {
        if UserDefaults.standard.dataSourceEnabled(DataSources.port) {
            mixins.append(PortMap(repository: tileRepository))
        }
    }
}

class NavigationalMapMixins: MapMixins {
    var subscriptions = Set<AnyCancellable>()
    var navigationalWarningMap = NavigationalWarningMap()
    
    override init() {
        super.init()
        let navareaMap = GeoPackageMap(
            fileName: "navigation_areas",
            tableName: "navigation_areas",
            index: 0
        )
        let backgroundMap = GeoPackageMap(
            fileName: "natural_earth_1_100",
            tableName: "Natural Earth",
            polygonColor: Color.dynamicLandColor,
            index: 1
        )
        self.mixins = [NavigationalWarningFetchMap(), navareaMap, backgroundMap]
    }
}

struct MarlinMap: UIViewRepresentable, MarlinMapProtocol {
    var notificationOnTap: NSNotification.Name = .MapItemsTapped
    var notificationOnLongPress: NSNotification.Name = .MapLongPress
    var focusNotification: NSNotification.Name = .FocusMapOnItem
    @State var name: String

    @ObservedObject var mixins: MapMixins
    @StateObject var mapState: MapState = MapState()
    var allowMapTapsOnItems: Bool = true
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: UIScreen.main.bounds)
        // double tap recognizer has no action
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(doubleTapRecognizer)
                
        let singleTapGestureRecognizer = MapSingleTap(coordinator: context.coordinator, mapView: mapView)
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        singleTapGestureRecognizer.delegate = context.coordinator
        singleTapGestureRecognizer.require(toFail: doubleTapRecognizer)
        mapView.addGestureRecognizer(singleTapGestureRecognizer)
        
        let longPressGestureRecognizer = MapLongPress(coordinator: context.coordinator, mapView: mapView)
        mapView.addGestureRecognizer(longPressGestureRecognizer)
        
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.isPitchEnabled = false
        mapView.showsCompass = false
        mapView.tintColor = UIColor(Color.primaryColorVariant)
        mapView.accessibilityLabel = name
        
        context.coordinator.mapView = mapView
        if let region = context.coordinator.currentRegion {
            context.coordinator.setMapRegion(region: region)
        }
    
        mapView.register(
            EnlargedAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: EnlargedAnnotationView.ReuseID
        )

        for mixin in mixins.mixins {
            mixin.setupMixin(mapState: mapState, mapView: mapView)
        }
        context.coordinator.mixins = mixins.mixins
        context.coordinator.allowMapTapsOnItems = allowMapTapsOnItems
        return mapView
    }

    func setupScale(mapView: MKMapView, context: Context) {
        let scale = context.coordinator.mapScale ?? mapView.subviews.first { view in
            return (view as? MKScaleView) != nil
        }

        if mapState.showMapScale {
            if scale == nil {
                let scale = MKScaleView(mapView: mapView)
                scale.scaleVisibility = .visible // always visible
                scale.isAccessibilityElement = true
                scale.accessibilityLabel = "Map Scale"
                scale.translatesAutoresizingMaskIntoConstraints = false
                mapView.addSubview(scale)

                NSLayoutConstraint.activate([
                    scale.centerXAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.centerXAnchor),
                    scale.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
                context.coordinator.mapScale = scale
            } else if let scale = scale {
                mapView.addSubview(scale)
                NSLayoutConstraint.activate([
                    scale.centerXAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.centerXAnchor),
                    scale.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -16)
                ])
            }
        } else if let scale = scale {
            scale.removeFromSuperview()
        }
    }

    func setMapLocation(context: Context) {
        if let center = mapState.center, 
            center.center.latitude != context.coordinator.setCenter?.latitude,
            center.center.longitude != context.coordinator.setCenter?.longitude {
            context.coordinator.setMapRegion(region: center)
            context.coordinator.setCenter = center.center
        }

        if let center = mapState.forceCenter, context.coordinator.forceCenterDate != mapState.forceCenterDate {
            context.coordinator.setMapRegion(region: center)
            context.coordinator.forceCenterDate = mapState.forceCenterDate
        }
    }

    func setMapType(mapView: MKMapView, context: Context) {
        if mapState.mapType == ExtraMapTypes.osm.rawValue {
            if context.coordinator.osmOverlay == nil {
                context.coordinator.osmOverlay 
                = MKTileOverlay(urlTemplate: "https://osm.gs.mil/tiles/default/{z}/{x}/{y}.png")
                context.coordinator.osmOverlay?.tileSize = CGSize(width: 512, height: 512)
                context.coordinator.osmOverlay?.canReplaceMapContent = true
            }
            mapView.removeOverlay(context.coordinator.osmOverlay!)
            mapView.insertOverlay(context.coordinator.osmOverlay!, at: 0, level: .aboveRoads)
        } else if let mkmapType = MKMapType(rawValue: UInt(mapState.mapType)) {
            mapView.mapType = mkmapType
            if let osmOverlay = context.coordinator.osmOverlay {
                mapView.removeOverlay(osmOverlay)
            }
        }
    }

    func setGrids(mapView: MKMapView, context: Context) {
        if mapState.showGARS {
            if context.coordinator.garsOverlay == nil {
                context.coordinator.garsOverlay = GARSTileOverlay(512, 512)
            }
            mapView.addOverlay(context.coordinator.garsOverlay!, level: .aboveRoads)
        } else {
            if let garsOverlay = context.coordinator.garsOverlay {
                mapView.removeOverlay(garsOverlay)
            }
        }

        if mapState.showMGRS {
            if context.coordinator.mgrsOverlay == nil {
                context.coordinator.mgrsOverlay = MGRSTileOverlay(512, 512)
            }
            mapView.addOverlay(context.coordinator.mgrsOverlay!, level: .aboveRoads)
        } else {
            if let mgrsOverlay = context.coordinator.mgrsOverlay {
                mapView.removeOverlay(mgrsOverlay)
            }
        }
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.mapView = mapView
        context.coordinator.allowMapTapsOnItems = allowMapTapsOnItems

        setupScale(mapView: mapView, context: context)

        setMapLocation(context: context)

        if context.coordinator.trackingModeSet != MKUserTrackingMode(rawValue: mapState.userTrackingMode) {
            mapView.userTrackingMode = MKUserTrackingMode(rawValue: mapState.userTrackingMode) ?? .none
            context.coordinator.trackingModeSet = MKUserTrackingMode(rawValue: mapState.userTrackingMode)
        }
                
        setMapType(mapView: mapView, context: context)

        setGrids(mapView: mapView, context: context)

        // remove any mixins that were removed
        for mixin in context.coordinator.mixins
        where !mixins.mixins.contains(where: { mixinFromMixins in
            mixinFromMixins.uuid == mixin.uuid
        }) {
            // this means it was removed
            mixin.removeMixin(mapView: mapView, mapState: mapState)
        }
        
        for mixin in mixins.mixins {
            if !context.coordinator.mixins.contains(where: { mixinFromCoordinator in
                mixinFromCoordinator.uuid == mixin.uuid
            }) {
                // this means it is new
                mixin.setupMixin(mapState: mapState, mapView: mapView)
            } else {
                // just update it
                mixin.updateMixin(mapView: mapView, mapState: mapState)
            }
        }
        context.coordinator.mixins = mixins.mixins
    }
 
    func makeCoordinator() -> MapCoordinator {
        return MarlinMapCoordinator(self, focusNotification: focusNotification)
    }

}

protocol MapCoordinator: MKMapViewDelegate, UIGestureRecognizerDelegate {
    var mapView: MKMapView? { get set }
    var mixins: [any MapMixin] { get set }
    var osmOverlay: MKTileOverlay? { get set }
    var garsOverlay: GARSTileOverlay? { get set }
    var mgrsOverlay: MGRSTileOverlay? { get set }
    var mapScale: MKScaleView? { get set }
    var currentRegion: MKCoordinateRegion? { get set }
    var allowMapTapsOnItems: Bool { get set }
    
    var setCenter: CLLocationCoordinate2D? { get set }
    var trackingModeSet: MKUserTrackingMode? { get set }
    
    var forceCenterDate: Date? { get set }
    var centerDate: Date? { get set }
    
    var marlinMap: MarlinMapProtocol { get set }
    
    var focusedAnnotation: EnlargedAnnotation? { get set }
    
    func setMapRegion(region: MKCoordinateRegion)
    func singleTapGesture(tapGestureRecognizer: UITapGestureRecognizer)
    func handleTappedItems(annotations: [MKAnnotation], items: [any DataSource], itemKeys: [String: [String]], mapName: String)
    func longPressGesture(longPressGestureRecognizer: UILongPressGestureRecognizer)
}

extension MapCoordinator {
    func setMapRegion(region: MKCoordinateRegion) {
        currentRegion = region
        self.mapView?.setRegion(region, animated: true)
    }
    
    func addAnnotation(annotation: MKAnnotation) {
        mapView?.addAnnotation(annotation)
    }
    
    func focusItem(notification: FocusMapOnItemNotification) {
        if let focusedAnnotation = focusedAnnotation {
            UIView.animate(
                withDuration: 0.5,
                delay: 0.0,
                options: .curveEaseInOut,
                animations: {
                    focusedAnnotation.shrinkAnnotation()
                },
                completion: { _ in
                    self.mapView?.removeAnnotation(focusedAnnotation)
                }
            )
            self.focusedAnnotation = nil
        }
        if let dataSource = notification.item {
            if notification.zoom, let warning = dataSource as? NavigationalWarning, let region = warning.region {
                let span = region.span
                let adjustedCenter = CLLocationCoordinate2D(
                    latitude: region.center.latitude - (span.latitudeDelta / 4.0),
                    longitude: region.center.longitude)
                if CLLocationCoordinate2DIsValid(adjustedCenter) {
                    let newRegion = MKCoordinateRegion(
                        center: adjustedCenter,
                        span: MKCoordinateSpan(
                            latitudeDelta: span.latitudeDelta + (span.latitudeDelta / 4.0),
                            longitudeDelta: span.longitudeDelta))
                    setMapRegion(region: newRegion)
                }
                
            } else {
                let span = mapView?.region.span ?? MKCoordinateSpan(
                    zoomLevel: 17,
                    pixelWidth: Double(mapView?.frame.size.width ?? UIScreen.main.bounds.width))
                let adjustedCenter = CLLocationCoordinate2D(
                    latitude: dataSource.coordinate.latitude - (span.latitudeDelta / 4.0),
                    longitude: dataSource.coordinate.longitude)
                if CLLocationCoordinate2DIsValid(adjustedCenter) {
                    setMapRegion(region: MKCoordinateRegion(center: adjustedCenter, span: span))
                }
            }
        }
        
        guard let mapItem = notification.item as? MapImage else {
            return
        }
        
        let enlarged = EnlargedAnnotation(mapImage: mapItem)
        enlarged.markForEnlarging()
        focusedAnnotation = enlarged
        mapView?.addAnnotation(enlarged)
    }
    
    func mapTap(tapPoint: CGPoint, gesture: UITapGestureRecognizer, mapView: MKMapView?) {
        guard let mapView = mapView, allowMapTapsOnItems else {
            return
        }
        
        mapView.isZoomEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            mapView.isZoomEnabled = true
        }
        
        let tapCoord = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        var annotationsTapped: [MKAnnotation] = []
        let visibleMapRect = mapView.visibleMapRect
        let annotationsVisible = mapView.annotations(in: visibleMapRect)
        
        for annotation in annotationsVisible {
            if let mkAnnotation = annotation as? MKAnnotation, let view = mapView.view(for: mkAnnotation) {
                let location = gesture.location(in: view)
                if view.bounds.contains(location) {
                    if let annotation = annotation as? MKClusterAnnotation {
                        if mapView.zoomLevel >= MKMapView.MAX_CLUSTER_ZOOM {
                            annotationsTapped.append(contentsOf: annotation.memberAnnotations)
                        } else {
                            mapView.showAnnotations(annotation.memberAnnotations, animated: true)
                            return
                        }
                    } else {
                        annotationsTapped.append(mkAnnotation)
                    }
                }
            }
        }
        
        var items: [any DataSource] = []
        var itemKeys: [String: [String]] = [:]
        for mixin in marlinMap.mixins.mixins.reversed() {
            if let matchedItems = mixin.items(at: tapCoord, mapView: mapView, touchPoint: tapPoint) {
                items.append(contentsOf: matchedItems)
            }
            let matchedItemKeys = mixin.itemKeys(at: tapCoord, mapView: mapView, touchPoint: tapPoint)
            itemKeys.merge(matchedItemKeys) { current, new in
                current + new
            }
        }
        handleTappedItems(annotations: annotationsTapped, items: items, itemKeys: itemKeys, mapName: marlinMap.name)
    }
}

protocol MarlinMapProtocol {
    var mixins: MapMixins { get set }
    var mapState: MapState { get }
    var name: String { get set }
    var notificationOnTap: NSNotification.Name { get set }
    var notificationOnLongPress: NSNotification.Name { get set }
}

class MarlinMapCoordinator: NSObject, MapCoordinator {
    
    var osmOverlay: MKTileOverlay?
    var garsOverlay: GARSTileOverlay?
    var mgrsOverlay: MGRSTileOverlay?

    var mapView: MKMapView?
    var mapScale: MKScaleView?
    var marlinMap: MarlinMapProtocol
    var focusedAnnotation: EnlargedAnnotation?
    var focusMapOnItemSink: AnyCancellable?

    var setCenter: CLLocationCoordinate2D?
    var trackingModeSet: MKUserTrackingMode?
    
    var forceCenterDate: Date?
    var centerDate: Date?
    
    var currentRegion: MKCoordinateRegion?
    
    var mixins: [any MapMixin] = []
    
    var allowMapTapsOnItems: Bool = true
    
    init(_ marlinMap: MarlinMapProtocol, focusNotification: NSNotification.Name) {
        self.marlinMap = marlinMap
        super.init()
        
        focusMapOnItemSink =
        NotificationCenter.default.publisher(for: focusNotification)
            .compactMap {$0.object as? FocusMapOnItemNotification}
            .sink(receiveValue: { [weak self] in
                NSLog("Focus notification recieved")
                self?.focusItem(notification: $0)
            })
    }
    
    func handleTappedItems(annotations: [MKAnnotation], items: [DataSource], itemKeys: [String: [String]], mapName: String) {
        let notification = MapItemsTappedNotification(annotations: annotations, items: items, itemKeys: itemKeys, mapName: mapName)
        NotificationCenter.default.post(name: marlinMap.notificationOnTap, object: notification)
    }
    
    @objc func singleTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let mapGesture = tapGestureRecognizer as? MapSingleTap, let mapView = mapGesture.mapView else {
            return
        }
        if tapGestureRecognizer.state == .ended {
            self.mapTap(
                tapPoint: tapGestureRecognizer.location(in: mapView),
                gesture: tapGestureRecognizer,
                mapView: mapView)
        }
    }
    
    @objc func longPressGesture(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard let mapGesture = longPressGestureRecognizer as? MapLongPress, let mapView = mapGesture.mapView else {
            return
        }
        
        if mapGesture.state == .began {
            let coordinate = mapView.convert(mapGesture.location(in: mapView), toCoordinateFrom: mapView)
            NotificationCenter.default.post(name: marlinMap.notificationOnLongPress, object: coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            
            guard let annotation = view.annotation as? EnlargedAnnotation else {
                continue
            }
            NSLog("check if should enlarge \(annotation.shouldEnlarge)")
            if annotation.shouldEnlarge {
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                    annotation.enlargeAnnoation()
                }
            }
            
            if annotation.shouldShrink {
                // have to enlarge it without animmation because it is added to the map at the original size
                annotation.enlargeAnnoation()
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut) {
                    annotation.shrinkAnnotation()
                    mapView.removeAnnotation(annotation)
                }
            }
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderableOverlay = overlay as? OverlayRenderable {
            return renderableOverlay.renderer
        }
        for mixin in marlinMap.mixins.mixins {
            if let renderer = mixin.renderer(overlay: overlay) {
                return renderer
            }
        }
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let enlarged = annotation as? EnlargedAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: EnlargedAnnotationView.ReuseID,
                for: enlarged)
            let mapImage = enlarged.mapImage
            let mapImages = mapImage.mapImage(marker: true, zoomLevel: 36, tileBounds3857: nil, context: nil)
            var finalImage: UIImage? = mapImages.first
            if mapImages.count > 1 {
                for mapImage in mapImages.suffix(from: 1) {
                    finalImage = UIImage.combineCentered(image1: finalImage, image2: mapImage)
                }
            }
            annotationView.image = finalImage
            var size = CGSize(width: 40, height: 40)
            let max = max(finalImage?.size.height ?? 40, finalImage?.size.width ?? 40)
            size.width *= ((finalImage?.size.width ?? 40) / max)
            size.height *= ((finalImage?.size.height ?? 40) / max)
            annotationView.frame.size = size
            annotationView.canShowCallout = false
            annotationView.isEnabled = false
            annotationView.accessibilityLabel = "Enlarged"
            annotationView.zPriority = .max
            annotationView.selectedZPriority = .max

            enlarged.annotationView = annotationView
            return annotationView
        }
        for mixin in marlinMap.mixins.mixins {
            if let view = mixin.viewForAnnotation(annotation: annotation, mapView: mapView) {
                return view
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        for mixin in marlinMap.mixins.mixins {
            mixin.regionDidChange(mapView: mapView, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        DispatchQueue.main.async { [self] in
            marlinMap.mapState.userTrackingMode = mode.rawValue
        }
    }
    
    func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        for mixin in marlinMap.mixins.mixins {
            mixin.traitCollectionUpdated(previous: previousTraitCollection)
        }
    }
}

class EnlargedAnnotation: NSObject, MKAnnotation {
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifierWhenShrunk: String?
    
    var clusteringIdentifier: String?
    
    var annotationView: MKAnnotationView?
    
    var color: UIColor {
        return UIColor.clear
    }
    
    var coordinate: CLLocationCoordinate2D
    var mapImage: MapImage
    
    init(mapImage: MapImage) {
        coordinate = mapImage.coordinate
        self.mapImage = mapImage
    }
    
    func markForEnlarging() {
        clusteringIdentifier = nil
        shouldEnlarge = true
    }
    
    func markForShrinking() {
        clusteringIdentifier = clusteringIdentifierWhenShrunk
        shouldShrink = true
    }
    
    func enlargeAnnoation() {
        guard let annotationView = annotationView else {
            return
        }
        enlarged = true
        shouldEnlarge = false
        annotationView.clusteringIdentifier = nil
        let currentOffset = annotationView.centerOffset
        annotationView.transform = annotationView.transform.scaledBy(x: 2.0, y: 2.0)
        annotationView.centerOffset = CGPoint(x: currentOffset.x * 2.0, y: currentOffset.y * 2.0)
    }
    
    func shrinkAnnotation() {
        guard let annotationView = annotationView else {
            return
        }
        enlarged = false
        shouldShrink = false
        annotationView.clusteringIdentifier = clusteringIdentifier
        let currentOffset = annotationView.centerOffset
        annotationView.transform = annotationView.transform.scaledBy(x: 0.5, y: 0.5)
        annotationView.centerOffset = CGPoint(x: currentOffset.x * 0.5, y: currentOffset.y * 0.5)
    }
}

class EnlargedAnnotationView: MKAnnotationView {
    static let ReuseID = "enlarged"
    
    /// - Tag: ClusterIdentifier
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
