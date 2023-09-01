//
//  CreateRouteView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI
import CoreLocation
import GeoJSON

struct CreateRouteView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var locationManager: LocationManager
    
    let maxFeatureAreaSize: CGFloat = 300
    @Binding var path: NavigationPath
    
    @State private var waypointsFrameSize: CGSize = .zero
    @State private var firstWaypointFrameSize: CGSize = .zero
    @State private var lastWaypointFrameSize: CGSize = .zero
    @State private var instructionsFrameSize: CGSize = .zero
    @State var waypoints: [AnyGeoJSONExportable] = []
    
    @State var routeViewModel: RouteViewModel = RouteViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Route Name")
                    .overline()
                TextField("Route Name", text: $routeViewModel.routeName)
                    .keyboardType(.default)
                    .underlineTextFieldWithLabel()
                    .accessibilityElement()
                    .accessibilityLabel("Route Name input")
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, 8)
            sizingOnlyStack()
                .frame(maxWidth: waypointsFrameSize.width, maxHeight: waypointsFrameSize.height)
                .overlay {
                    routeList()
                }
            RouteMapView(path: $path, waypoints: $waypoints, routeViewModel: routeViewModel)
                .edgesIgnoringSafeArea([.leading, .trailing])
        }
        .onAppear {
            if waypoints.count == 0 {
                if let coordinate = locationManager.lastLocation?.coordinate {
                    waypoints.append(AnyGeoJSONExportable(CommonDataSource(name: "Your Current Location", location: coordinate)))
                }
            }
        }
        .onChange(of: waypoints, perform: { newValue in
            var features: [Feature] = []
            for waypoint in waypoints {
                let waypoint = waypoint.base
                    for feature in waypoint.geoJsonFeatures {
                        features.append(feature)
                    }
                
            }
            let featureCollection = FeatureCollection(features: features)
            routeViewModel.routeFeatureCollection = featureCollection
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if waypoints.count > 1 {
                    Button("Save") {
                        routeViewModel.createRoute(context: managedObjectContext)
                    }
                }
            }
        }
        .navigationTitle(Route.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func waypointRow(waypointViewBuilder: any DataSourceViewBuilder, first: Bool = false, last: Bool = false) -> some View {
        HStack {
            Group {
                DataSourceCircleImage(dataSource: waypointViewBuilder, size: 12)
                HStack {
                    VStack(alignment: .leading) {
                        Text(waypointViewBuilder.itemTitle)
                            .font(Font.body2)
                            .foregroundColor(Color.onSurfaceColor)
                            .fixedSize(horizontal: false, vertical: true)
                        if let waypointLocation = waypointViewBuilder as? DataSourceLocation {
                            Text(waypointLocation.coordinate.format())
                                .overline()
                        }
                    }
                    Spacer()
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
            }.padding([.top, .bottom], 8)
        }
        .background(HStack {
            let topPadding = first ? firstWaypointFrameSize.height / 2.0 : 0
            let bottomPadding = last ? lastWaypointFrameSize.height / 2.0 : 0
            Rectangle()
                .fill(Color.onSurfaceColor.opacity(0.45))
                .frame(maxWidth: 2, maxHeight: .infinity)
                .padding(.leading, 9)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
            Spacer()
        })
    }
    
    @ViewBuilder
    func instructions() -> some View {
        Text("Select a feature to add to the route, long press to add custom point, drag to reorder")
            .font(Font.overline)
            .frame(maxWidth: .infinity, alignment: .center)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(Color.onSurfaceColor)
            .opacity(0.8)
            .listRowBackground(Color.clear)
            .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowSeparator(.hidden, edges: .bottom)
    }
    
    @ViewBuilder
    func routeList() -> some View {
        VStack {
            List {
                ForEach(waypoints, id: \.uniqueId) { waypoint in
                    if let waypointViewBuilder = waypoint.base as? any DataSourceViewBuilder {
                        waypointRow(waypointViewBuilder: waypointViewBuilder, first: !waypoints.isEmpty && waypoints.first! == waypoint, last: !waypoints.isEmpty && waypoints.last! == waypoint)
                            
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive)  {
                                    waypoints.removeAll { exportable in
                                        exportable.uniqueId == waypoint.uniqueId
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .accessibilityElement()
                                .accessibilityLabel("remove waypoint \(waypoint.uniqueId)")
                                .tint(Color.red)
                            }
                            .listRowInsets(.init(top: 0, leading: 20, bottom: 0, trailing: 0))
                            .listRowSeparator(.hidden, edges: .top)
                            .listRowSeparator(.visible, edges: .bottom)
                    }
                }
                .onMove { from, to in
                    waypoints.move(fromOffsets: from, toOffset: to)
                }
                instructions()
            }
            .listStyle(.plain)
            .padding(.top, 10)
            .padding(.leading, -4)
            
            
        }
    }
    
    // this seems dumb, and it is.  This is used only for sizing because you cannot add swipe actions to anything
    // other than a list AND you can't get the content size of a list because, of course you can't
    // so we use this to create the right size, and set the list as an overlay because the list will take up all the room
    // that it is given
    @ViewBuilder
    func sizingOnlyStack() -> some View {
        VStack(spacing: 0) {
            ForEach(waypoints.indices, id: \.self) { i in
                if let waypointViewBuilder = waypoints[i].base as? any DataSourceViewBuilder {
                    waypointRow(waypointViewBuilder: waypointViewBuilder)
                        .opacity(0)
                        .overlay(
                            GeometryReader { geo in
                                Color.clear.onAppear {
                                    if i == waypoints.indices.lowerBound {
                                        firstWaypointFrameSize = CGSize(width: .infinity, height: geo.size.height)
                                    }
                                    if i == waypoints.indices.upperBound.advanced(by: -1) {
                                        lastWaypointFrameSize = CGSize(width: .infinity, height: geo.size.height)
                                    }
                                }
                                .onChange(of: geo.size) { geoSize in
                                    if i == waypoints.indices.lowerBound {
                                        firstWaypointFrameSize = CGSize(width: .infinity, height: geo.size.height)
                                    }
                                    if i == waypoints.indices.upperBound.advanced(by: -1) {
                                        lastWaypointFrameSize = CGSize(width: .infinity, height: geo.size.height)
                                    }
                                }
                            }
                        )
                }
            }
            instructions()
                .opacity(0)
                .overlay(
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            instructionsFrameSize = CGSize(width: .infinity, height: geo.size.height)
                        }
                        .onChange(of: geo.size) { geoSize in
                            instructionsFrameSize = CGSize(width: .infinity, height: geo.size.height)
                        }
                    }
                )
        }
        .padding(16)
        
        .overlay(
            GeometryReader { geo in
                Color.clear.onAppear {
                    waypointsFrameSize = CGSize(width: .infinity, height: min(geo.size.height, maxFeatureAreaSize))
                }
                .onChange(of: geo.size) { geoSize in
                    waypointsFrameSize = CGSize(width: .infinity, height: min(geo.size.height, maxFeatureAreaSize))
                }
            }
        )
    }
}
