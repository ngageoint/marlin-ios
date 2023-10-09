//
//  RouteList.swift
//  Marlin
//
//  Created by Daniel Barela on 8/14/23.
//

import SwiftUI

struct RouteList: View {
    @EnvironmentObject var routeRepository: RouteRepositoryManager
    @StateObject var viewModel: RoutesViewModel = RoutesViewModel()
    
    @Binding var path: NavigationPath
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(viewModel.routes) { route in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(route.name ?? "")")
                            .primary()
                        Text("Created \(route.createdTime?.formatted() ?? "")")
                            .overline()
                        HStack {
                            if let first = route.waypointArray.first {
                                if let dataSourceKey = first.dataSource, let type = DataSourceType.fromKey(dataSourceKey)?.toDataSource() {
                                    DataSourceCircleImage(dataSource: type, size: 15)
                                }
                                if let ds = first.decodeToDataSource() as? DataSource {
                                    Text(ds.itemTitle)
                                        .font(Font.overline)
                                        .foregroundColor(Color.onSurfaceColor)
                                        .opacity(0.8)
                                }
                            }
                            Image(systemName: "ellipsis")
                            if let last = route.waypointArray.last {
                                Group {
                                    if let dataSourceKey = last.dataSource, let type = DataSourceType.fromKey(dataSourceKey)?.toDataSource() {
                                        DataSourceCircleImage(dataSource: type, size: 15)
                                    }
                                    if let ds = last.decodeToDataSource() as? DataSource  {
                                        Text(ds.itemTitle)
                                            .font(Font.overline)
                                            .foregroundColor(Color.onSurfaceColor)
                                            .opacity(0.8)
                                    }
                                }
                                .onTapGesture {
                                    if let dataSource = last.dataSource, let itemKey = last.itemKey, let waypointURL = last.waypointId {
                                        
                                        path.append(MarlinRoute.dataSourceRouteDetail(dataSourceKey: dataSource, itemKey: itemKey, waypointURI: waypointURL))
                                    }
                                }
                            }
                        }
                        if let distance = route.nauticalMilesDistance {
                            Text("Total Distance: \(distance)")
                                .overline()
                        }
                    }
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    path.append(MarlinRoute.editRoute(routeURI: route.routeURL))
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive)  {
                        print("delete")
                        viewModel.deleteRoute(route: route.routeURL)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityElement()
                    .accessibilityLabel("remove route \(route.name ?? "")")
                    .tint(Color.red)
                }
            }
            CreateRouteButton()
        }
        .emptyPlaceholder(viewModel.routes) {
            Group {
                if viewModel.loaded {
                    RouteListEmptyState()
                } else {
                    RouteListLoadingState()
                }
            }
        }
        .navigationTitle(Route.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            viewModel.repository = routeRepository
            viewModel.fetchRoutes()
            Metrics.shared.dataSourceList(dataSource: Route.self)
        }
    }
}
