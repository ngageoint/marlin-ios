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
    
    init(navArea: String, mapName: String?) {
        self.navArea = navArea
        self.mapName = mapName
        self._currentNavigationalWarningsSections = SectionedFetchRequest<String, NavigationalWarning>(entity: NavigationalWarning.entity(), sectionIdentifier: \NavigationalWarning.navArea!, sortDescriptors: [NSSortDescriptor(keyPath: \NavigationalWarning.navArea, ascending: false), NSSortDescriptor(keyPath: \NavigationalWarning.issueDate, ascending: false)], predicate: NSPredicate(format: "navArea = %@", navArea))
    }
    
    var body: some View {
        ForEach(currentNavigationalWarningsSections) { section in
            NavigationalWarningSectionRow(section: section, mapName: mapName)
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
        return List {
            if let navArea = generalLocation.currentNavAreaName {
                CurrentNavigationalWarningSection(navArea: navArea, mapName: mapName)
            }
            ForEach(navigationalWarningsSections) { section in
                NavigationalWarningSectionRow(section: section, mapName: mapName)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "Navigation Area")")
            }
            .accessibilityElement(children: .contain)
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            .accessibilityElement(children: .contain)
            
            if showUnparsedNavigationalWarnings {
                NavigationLink {
                    NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(noParsedLocationNavigationalWarnings), navArea: "Unknown", mapName: mapName)
                        .accessibilityElement(children: .contain)
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
        .listStyle(.plain)
        .listRowBackground(Color.surfaceColor)
        .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
        .onAppear {
            navigationalWarningsSections.nsPredicate = NSPredicate(format: "navArea != %@", generalLocation.currentNavAreaName ?? "")
        }
        .accessibilityElement(children: .contain)
    }
}
