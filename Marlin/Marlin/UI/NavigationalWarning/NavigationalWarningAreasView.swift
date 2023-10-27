//
//  NavigationalWarningAreasView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/24/23.
//

import SwiftUI

struct CurrentNavigationalWarningSection: View {
    var navArea: String
    var mapName: String?
    
    @SectionedFetchRequest<String, NavigationalWarning>
    var currentNavigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    @Binding var path: NavigationPath
    
    init(navArea: String, mapName: String?, path: Binding<NavigationPath>) {
        self.navArea = navArea
        self.mapName = mapName
        self._currentNavigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea = %@", navArea))
        _path = path
    }
    
    var body: some View {
        ForEach(currentNavigationalWarningsSections) { section in
            NavigationalWarningSectionRow(section: section, mapName: mapName, path: $path)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "Navigation Area") (Current)")
        }
        .accessibilityElement(children: .contain)
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
    }
}

struct NavigationalWarningAreasView: View {
    @ObservedObject var generalLocation = GeneralLocation.shared
    @State var navArea: String?
    var mapName: String?
    @Binding var path: NavigationPath
    
    @AppStorage("showUnparsedNavigationalWarnings") var showUnparsedNavigationalWarnings = false
    
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
        Self._printChanges()
        return ZStack(alignment: .bottomTrailing) {
            List {
                if let navArea = generalLocation.currentNavAreaName {
                    CurrentNavigationalWarningSection(navArea: navArea, mapName: mapName, path: $path)
                }
                ForEach(navigationalWarningsSections) { section in
                    NavigationalWarningSectionRow(section: section, mapName: mapName, path: $path)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "Navigation Area")")
                }
                .accessibilityElement(children: .contain)
                .listRowBackground(Color.surfaceColor)
                .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
                .accessibilityElement(children: .contain)
                
                if showUnparsedNavigationalWarnings {
                    NavigationLink(value: NavigationalWarningSection(id: "Unknown", warnings: Array<NavigationalWarning>(noParsedLocationNavigationalWarnings))) {
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
            .listStyle(.plain)
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            .onChange(of: generalLocation.currentNavAreaName, perform: { newValue in
                navigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea != %@", newValue ?? "")
            })
            .onAppear {
                navigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea != %@", generalLocation.currentNavAreaName ?? "")
            }
            .accessibilityElement(children: .contain)
            NavigationLink(value: MarlinRoute.exportGeoPackage([DataSourceExportRequest(filterable: DataSourceDefinitions.filterableFromDefintion(NavigationalWarning.definition), filters: UserDefaults.standard.filter(NavigationalWarning.definition))])) {
                Label(
                    title: {},
                    icon: { Image(systemName: "square.and.arrow.down")
                            .renderingMode(.template)
                    }
                )
            }
            .isDetailLink(false)
            .fixedSize()
            .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini, foregroundColor: Color.onPrimaryColor, backgroundColor: Color.primaryColor))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Export Button")
            .padding(16)
        }
    }
}
