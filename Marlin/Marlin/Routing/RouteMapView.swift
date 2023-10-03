//
//  RouteMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/21/23.
//

import SwiftUI
import MapKit
import Combine
import GeoJSON
import CoreData
import CoreLocation

class RouteViewModel: ObservableObject, Identifiable {
    var locationManager = LocationManager.shared()
    var route: Route?
    var routeURI: URL? {
        didSet {
            let context = PersistenceController.current.viewContext
            if let routeURI = routeURI, let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: routeURI), let route = try? context.existingObject(with: id) as? Route {
                self.route = route
                routeName = route.name ?? ""
                routeDistance = route.distanceMeters
                waypoints = []
                for waypoint in route.waypointArray {
                    if let exportable = waypoint.decodeToDataSource() as? any GeoJSONExportable {
                        addWaypoint(waypoint: AnyGeoJSONExportable(exportable))
                    }
                }
            }
        }
    }
    
    @Published var routeMKLine: MKGeodesicPolyline?
    @Published var routeFeatureCollection: FeatureCollection? {
        didSet {
            if let routeFeatureCollection = routeFeatureCollection {
                routeMKLine = MKShape.fromFeatureCollection(featureCollection: routeFeatureCollection)
            } else {
                routeMKLine = nil
            }
        }
    }
    
    @Published var waypoints: [AnyGeoJSONExportable] = []
    
    @Published var routeName: String = ""
    
    @Published var routeDistance: Double = 0.0
    var measurementFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
        return measurementFormatter
    }
    var nauticalMilesDistance: String? {
        if routeDistance != 0.0 {
            let metersMeasurement = NSMeasurement(doubleValue: routeDistance, unit: UnitLength.meters)
            let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles)
            return measurementFormatter.string(from: convertedMeasurement)
        }
        return nil
    }
    
    init() {
        if let coordinate = locationManager.lastLocation?.coordinate, CLLocationCoordinate2DIsValid(coordinate) {
            addWaypoint(waypoint: AnyGeoJSONExportable(CommonDataSource(name: "Your Current Location", location: coordinate)))
        }
    }
    
    func reorder(fromOffsets source: IndexSet, toOffset destination: Int) {
        waypoints.move(fromOffsets: source, toOffset: destination)
        setupFeatureCollection()
    }
    
    func removeWaypoint(waypoint: AnyGeoJSONExportable) {
        waypoints.removeAll { exportable in
            exportable.uniqueId == waypoint.uniqueId
        }
        setupFeatureCollection()
    }
    
    func addWaypoint(waypoint: AnyGeoJSONExportable) {
        waypoints.append(waypoint)
        setupFeatureCollection()
    }
    
    func setupFeatureCollection() {
        var features: [Feature] = []
        routeDistance = 0.0
        var previousCoordinate: CLLocation?
        for waypoint in waypoints {
            let waypoint = waypoint.base
            if let centerPoint = waypoint.sfGeometry?.degreesCentroid() {
                let location = CLLocation(latitude: centerPoint.y.doubleValue, longitude: centerPoint.x.doubleValue)
                if let previousCoordinate = previousCoordinate {
                    routeDistance += previousCoordinate.distance(from: location)
                }
                previousCoordinate = location
            }
            for feature in waypoint.geoJsonFeatures {
                features.append(feature)
            }
            
        }
        let featureCollection = FeatureCollection(features: features)
        routeFeatureCollection = featureCollection
    }
    
    func createRoute(context: NSManagedObjectContext) {
        context.perform {
            var route: Route? = self.route
            
            if route == nil {
                route = Route(context: context)
                route?.createdTime = Date()
            }
            if let route = route {
                route.updatedTime = Date()
                route.name = self.routeName
                route.distanceMeters = self.routeDistance
                var set: Set<RouteWaypoint> = Set<RouteWaypoint>()
                for (i,waypoint) in self.waypoints.enumerated() {
                    let routeWaypoint = RouteWaypoint(context: context)
                    routeWaypoint.dataSource = waypoint.key
                    routeWaypoint.json = waypoint.geoJson
                    routeWaypoint.order = Int64(i)
                    routeWaypoint.route = route
                    routeWaypoint.itemKey = waypoint.itemKey
                    set.insert(routeWaypoint)
                }
                route.waypoints = NSSet(set: set)
                if let routeFeatureCollection = self.routeFeatureCollection {
                    do {
                        let json = try JSONEncoder().encode(routeFeatureCollection)
                        let geoJson = String(data: json, encoding: .utf8)
                        if let geoJson = geoJson {
                            route.geojson = geoJson
                        }
                    } catch {
                        print("error is \(error)")
                    }
                }
                
                try? context.save()
            }
        }
    }
}

class RouteMixin: MapMixin {
    var uuid: UUID = UUID()
    var mapState: MapState?
    var cancellable = Set<AnyCancellable>()
    
    var currentRoute: MKGeodesicPolyline?
    var updatedRoute: MKGeodesicPolyline?
    
    var viewModel: RouteViewModel
    
    init(viewModel: RouteViewModel) {
        self.viewModel = viewModel
    }
    
    func setupMixin(mapState: MapState, mapView: MKMapView) {
        self.mapState = mapState
        viewModel.$routeMKLine
            .receive(on: RunLoop.main)
            .sink() { [weak self] mkline in
                self?.updatedRoute = mkline
                self?.refreshLine()
            }
            .store(in: &cancellable)
    }
    
    func removeMixin(mapView: MKMapView, mapState: MapState) {
        
    }
    
    func refreshLine() {
        DispatchQueue.main.async {
            self.mapState?.mixinStates["\(String(describing: RouteMixin.self))DataUpdated"] = Date()
        }
    }
    
    func updateMixin(mapView: MKMapView, mapState: MapState) {
        if let currentRoute = self.currentRoute {
            print("remove current route")
            mapView.removeOverlay(currentRoute)
        }
        print("adding mkline \(updatedRoute)")
        if let mkline = updatedRoute {
            mapView.addOverlay(mkline)
            self.currentRoute = mkline
        }
    }
}

extension Notification.Name {
    public static let RouteMapTapped = Notification.Name("RouteMapTapped")
    public static let RouteFocus = Notification.Name("RouteFocus")
    public static let RouteMapLongPress = Notification.Name("RouteMapLongPress")
}

struct RouteMapView: View {
    @State var showBottomSheet: Bool = false
    @StateObject var itemList: BottomSheetItemList = BottomSheetItemList()
    
    @Binding var path: NavigationPath
    
    @ObservedObject var routeViewModel: RouteViewModel

    let focusMapAtLocation = NotificationCenter.default.publisher(for: .FocusMapAtLocation)

    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    let mapItemsTappedPub = NotificationCenter.default.publisher(for: .RouteMapTapped)
    let longPressPub = NotificationCenter.default.publisher(for: .RouteMapLongPress)
    
    var body: some View {
        VStack {
            MarlinMap(notificationOnTap: .RouteMapTapped, notificationOnLongPress: .RouteMapLongPress, focusNotification: .RouteFocus, name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
        }
        .onAppear {
            mixins.mixins.append(RouteMixin(viewModel: routeViewModel))
        }
        .onReceive(focusMapAtLocation) { notification in
            mapState.forceCenter = notification.object as? MKCoordinateRegion
        }
        .overlay(bottomButtons(), alignment: .bottom)
        .overlay(topButtons(), alignment: .top)
        .onReceive(longPressPub) { output in
            guard let coordinate = output.object as? CLLocationCoordinate2D else {
                return
            }
            
            routeViewModel.addWaypoint(waypoint: AnyGeoJSONExportable(CommonDataSource(name: "User Added Location", location: coordinate)))
        }
        .onReceive(mapItemsTappedPub) { output in
            guard let notification = output.object as? MapItemsTappedNotification else {
                return
            }
            
            var bottomSheetItems: [BottomSheetItem] = []
            if let items = notification.items, !items.isEmpty {
                
                print("Route map items tapped")
                
                for item in items {
                    let bottomSheetItem = BottomSheetItem(item: item, mapName: "Route Map", zoom: false)
                    bottomSheetItems.append(bottomSheetItem)
                }
                itemList.bottomSheetItems = bottomSheetItems
                showBottomSheet.toggle()
            }

        }
        .sheet(isPresented: $showBottomSheet, onDismiss: {
            NSLog("dismissed")
            NotificationCenter.default.post(name: .RouteFocus, object: FocusMapOnItemNotification(item: nil))
        }) {
            MarlinBottomSheet(itemList: itemList, focusNotification: .RouteFocus) { dataSourceViewBuilder in
                VStack {
                    Text(dataSourceViewBuilder.itemTitle)
                    HStack {
                        Button("Add To Route") {
                            print("add to route")
                            if let exportable = dataSourceViewBuilder as? any GeoJSONExportable {
                                if let model = DataSourceType.fromKey(dataSourceViewBuilder.key)?.createModel(dataSource: dataSourceViewBuilder) as? any GeoJSONExportable {
                                    routeViewModel.addWaypoint(waypoint: AnyGeoJSONExportable(model))
                                }
                            }
                        }
                        .buttonStyle(MaterialButtonStyle(type:.text))
                    }
                }
            }
            .environmentObject(LocationManager.shared())
            .presentationDetents([.height(150)])
        }
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                SearchView(mapState: mapState)
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            DataSourceToggles()
                .padding(.leading, 8)
                .padding(.bottom, 30)
            
            Spacer()
                .frame(maxWidth: .infinity)
            
            // bottom right button stack
            VStack(alignment: .trailing, spacing: 16) {
                UserTrackingButton(mapState: mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}
