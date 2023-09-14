//
//  RouteList.swift
//  Marlin
//
//  Created by Daniel Barela on 8/14/23.
//

import SwiftUI

struct RouteList: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var path: NavigationPath

    @FetchRequest(sortDescriptors: [SortDescriptor(\.updatedTime, order: .reverse)])
    private var routes: FetchedResults<Route>
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List(routes) { route in
                VStack(alignment: .leading) {
                    Text("\(route.name ?? "")")
                        .primary()
                    Text("Created \(route.createdTime?.formatted() ?? "")")
                        .overline()
                    HStack {
                        if let first = route.waypointArray.first {
                            let _ = first.decodeToDataSource()
                            if let dataSourceKey = first.dataSource, let type = DataSourceType.fromKey(dataSourceKey)?.toDataSource() {
                                DataSourceCircleImage(dataSource: type, size: 15)
                            }
                            Text(first.itemKey ?? "")
                                .overline()
                        }
                        Image(systemName: "ellipsis")
                        if let last = route.waypointArray.last {
                            let _ = last.decodeToDataSource()
                            Group {
                                if let dataSourceKey = last.dataSource, let type = DataSourceType.fromKey(dataSourceKey)?.toDataSource() {
                                    DataSourceCircleImage(dataSource: type, size: 15)
                                }
                                Text(last.itemKey ?? "")
                                    .overline()
                            }
                            .onTapGesture {
                                if let dataSource = last.dataSource, let itemKey = last.itemKey {
                                    
                                    path.append(MarlinRoute.dataSourceRouteDetail(dataSourceKey: dataSource, itemKey: itemKey, waypointURI: last.objectID.uriRepresentation()))
                                }
                            }
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive)  {
                        managedObjectContext.perform {
                            managedObjectContext.delete(route)
                            try? managedObjectContext.save()
                        }
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