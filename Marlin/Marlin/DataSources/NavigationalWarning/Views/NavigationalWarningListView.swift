//
//  NavigationalWarningListView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var locationManager: LocationManager
    @StateObject var mapState: MapState = MapState()

    var navareaMap = GeoPackageMap(fileName: "navigation_areas", tableName: "navigation_areas", index: 0)
    var backgroundMap = GeoPackageMap(fileName: "natural_earth_1_100", tableName: "Natural Earth", polygonColor: Color.dynamicLandColor, index: 1)
    
    var body: some View {
        List {
            MarlinMap(name: "Navigational Warning List View Map", mixins: [navareaMap, backgroundMap], mapState: mapState)
                .frame(minHeight: 250, maxHeight: 250)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            NavigationalWarningAreasView(currentArea: locationManager.currentNavArea)
                .listRowBackground(Color.surfaceColor)
                .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        }
        .listStyle(.plain)
        .navigationTitle("Navigational Warnings")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
        .onAppear {
            if let lastLocation = locationManager.lastLocation {
                mapState.center = MKCoordinateRegion(center: lastLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 30, longitudeDelta: 30))
            }
            Metrics.shared.dataSourceList(dataSource: NavigationalWarning.self)
        }
    }
}

struct NavigationalWarningAreasView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, NavigationalWarning>
    var currentNavigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>

    @SectionedFetchRequest<String, NavigationalWarning>
    var navigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    init(currentArea: NavigationalWarningNavArea?) {
        self._currentNavigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea = %@", currentArea?.name ?? ""))
    
        self._navigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea != %@", currentArea?.name ?? ""))
    }
    
    var body: some View {
        ForEach(currentNavigationalWarningsSections) { section in
            NavigationLink {
                NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(section), navArea: section.id)
                    
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text("\(section.count) Active")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                    Spacer()
                    NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: Array<NavigationalWarning>(section))
                }
            }
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(NavigationalWarningNavArea.fromId(id: section.id)?.color ?? UIColor.clear))
                        .frame(maxWidth: 6, maxHeight: .infinity)
                    Spacer()
                }.padding([.leading, .top, .bottom], -8)
            )
        }
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        
        ForEach(navigationalWarningsSections) { section in
            NavigationLink {
                NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(section), navArea: section.id)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text("\(section.count) Active")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                    Spacer()
                    NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: Array<NavigationalWarning>(section))
                }
            }
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(NavigationalWarningNavArea.fromId(id: section.id)?.color ?? UIColor.clear))
                        .frame(maxWidth: 6, maxHeight: .infinity)
                    Spacer()
                }.padding([.leading, .top, .bottom], -8)
            )
        }
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
    }
}


struct NavigationalWarningListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationalWarningListView()
    }
}
