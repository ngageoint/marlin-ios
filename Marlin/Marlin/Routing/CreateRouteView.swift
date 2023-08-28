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
    @EnvironmentObject var locationManager: LocationManager

    let maxFeatureAreaSize: CGFloat = 300
    @Binding var path: NavigationPath
    
    @State private var contentSize: CGSize = .zero
    @State var waypoints: [any DataSource] = []
    
    @State var routeViewModel: RouteViewModel = RouteViewModel()
        
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Grid(alignment: .center, horizontalSpacing: 8, verticalSpacing: 4) {
                    GridRow {
                        if !waypoints.isEmpty, let firstWaypoint = waypoints[0] as? any DataSourceViewBuilder {
                            if type(of: firstWaypoint) == CommonDataSource.self {
                            Image(systemName: "target")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.blue)
                                .frame(width: 16, height: 16)
                                .padding(2)
                            } else {
                                DataSourceCircleImage(dataSource: firstWaypoint, size: 12)
                            }

                            TextField("Starting location", text: Binding.constant(firstWaypoint.itemTitle))
                                .borderedTextField()
                            Button {
                                waypoints.remove(at: 0)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .tint(Color.red)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("remove waypoint \(0)")
                        }
                    }

                    ForEach(waypoints.indices, id: \.self) { i in
                        if i != 0, let waypoint = waypoints[i] as? any DataSourceViewBuilder {
                            GridRow {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 16, height: 16)
                                    .padding([.top, .bottom], -10)
                            }
                            GridRow {
                                DataSourceCircleImage(dataSource: waypoint, size: 12)
                                TextField("Destination", text: Binding.constant(waypoint.itemTitle))
                                        .borderedTextField()
                                
                                Button {
                                    waypoints.remove(at: i)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .tint(Color.red)
                                }
                                .accessibilityElement()
                                .accessibilityLabel("remove waypoint \(i)")
                            }
                        }
                    }
                    GridRow {
                        Text("Select a feature to add to the route, long press to add custom point")
                            .secondary()
                            .padding(8)
                            .gridCellColumns(3)
                    }
                }
                .padding(16)
                .overlay(
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            contentSize = CGSize(width: .infinity, height: min(geo.size.height, maxFeatureAreaSize))
                        }
                        .onChange(of: geo.size) { geoSize in
                            contentSize = CGSize(width: .infinity, height: min(geo.size.height, maxFeatureAreaSize))
                        }
                    }
                )
            }
            .scrollDisabled(contentSize.height < maxFeatureAreaSize)
            .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
            RouteMapView(path: $path, waypoints: $waypoints, routeViewModel: routeViewModel)
                .edgesIgnoringSafeArea([.leading, .trailing])
        }
        .onAppear {
            if waypoints.count == 0 {
                waypoints.append(CommonDataSource(name: "Your Current Location", location: locationManager.lastLocation?.coordinate ?? kCLLocationCoordinate2DInvalid))
            }
        }
        .onChange(of: waypoints.count, perform: { newValue in
            print("waypoints changed \(waypoints)")
            var features: [Feature] = []
            for waypoint in waypoints {
                if let waypoint = waypoint as? GeoJSONExportable {
                    if let feature = waypoint.geoJsonFeature {
                        features.append(feature)
                    }
                }
            }
            let featureCollection = FeatureCollection(features: features)
            routeViewModel.routeFeatureCollection = featureCollection
        })
        .navigationTitle(Route.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
