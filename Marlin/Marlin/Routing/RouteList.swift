//
//  RouteList.swift
//  Marlin
//
//  Created by Daniel Barela on 8/14/23.
//

import SwiftUI

struct RouteList: View {
    @Binding var path: NavigationPath

    @FetchRequest(sortDescriptors: [SortDescriptor(\.updatedTime, order: .reverse)])
    private var routes: FetchedResults<Route>
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(routes) { route in
                VStack {
                    Text("Route")
                    Text("\(route.name ?? "")")
                    Text("geojson \(route.geojson ?? "")")
                }
            }
            CreateRouteButton()
        }
        .emptyPlaceholder(routes) {
            RouteListEmptyState()
        }
        .navigationTitle(Route.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            Metrics.shared.dataSourceList(dataSource: Route.self)
        }
    }
}
