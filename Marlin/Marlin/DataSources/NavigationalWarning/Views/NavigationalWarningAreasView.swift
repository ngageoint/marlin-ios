//
//  NavigationalWarningAreasView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/24/23.
//

import SwiftUI

struct NavigationalWarningAreasView<Location>: View where Location: LocationManagerProtocol {
    @EnvironmentObject var navState: NavState
    @ObservedObject var locationManager: Location
    
    var mapName: String?
    
    @AppStorage("showUnparsedNavigationalWarnings") var showUnparsedNavigationalWarnings = false
    
    @SectionedFetchRequest<String, NavigationalWarning>(
        sectionIdentifier: \NavigationalWarning.navArea!,
        sortDescriptors: [
            NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false),
            NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)],
        predicate: NSPredicate(format: "navArea = %@", ""))
    var currentNavigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    @SectionedFetchRequest<String, NavigationalWarning>(
        sectionIdentifier: \NavigationalWarning.navArea!,
        sortDescriptors: [
            NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false),
            NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)],
        predicate: NSPredicate(format: "navArea != %@", ""))
    var navigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false),
            NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)],
        predicate: NSPredicate(format: "locations == nil"),
        animation: .default)
    private var noParsedLocationNavigationalWarnings: FetchedResults<NavigationalWarning>
    
    var body: some View {
        Group {
            ForEach(currentNavigationalWarningsSections) { section in
                NavigationalWarningSectionRow(section: section, mapName: mapName)
            }
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            
            ForEach(navigationalWarningsSections) { section in
                NavigationalWarningSectionRow(section: section, mapName: mapName)
            }
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            
            if showUnparsedNavigationalWarnings {
                NavigationLink {
                    NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(noParsedLocationNavigationalWarnings), navArea: "Unknown", mapName: mapName)
                        .environmentObject(navState)
                } label: {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Unparsed Locations")
                                .font(Font.body1)
                                .foregroundColor(Color.onSurfaceColor)
                                .opacity(0.87)
                            Text("\(noParsedLocationNavigationalWarnings.count)")
                                .font(Font.caption)
                                .foregroundColor(Color.onSurfaceColor)
                                .opacity(0.6)
                        }
                        Spacer()
                    }
                }
                .isDetailLink(false)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Unparsed Locations Navigation Area")
                .padding(.leading, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .listRowBackground(Color.surfaceColor)
                .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            }
        }
        .onAppear {
            currentNavigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea = %@", locationManager.currentNavArea?.name ?? "")
            navigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea != %@", locationManager.currentNavArea?.name ?? "")
        }
        .onReceive(self.locationManager.objectWillChange) { _ in
            currentNavigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea = %@", locationManager.currentNavArea?.name ?? "")
            navigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea != %@", locationManager.currentNavArea?.name ?? "")
        }
    }
}
