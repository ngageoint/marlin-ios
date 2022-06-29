//
//  NavigationalWarningListView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI

struct NavigationalWarningListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var scheme: MarlinScheme
    
    @SectionedFetchRequest<String, NavigationalWarning>(
        sectionIdentifier: \.navArea!,
        sortDescriptors: [SortDescriptor(\.navArea, order: .reverse), SortDescriptor(\.issueDate, order: .reverse)]
    )
    var navigationalWarningsSections: SectionedFetchResults<String, NavigationalWarning>
    
    var body: some View {
        NavigationView {
            List {
                MarlinMap()
                    .mixin(GeoPackageMap(fileName: "natural_earth_1_100", tableName: "Natural Earth"))
                    .frame(minHeight: 250, maxHeight: 250)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                ForEach(navigationalWarningsSections) { section in
                    NavigationLink {
                        NavigationalWarningNavAreaListView(warnings: Array<NavigationalWarning>(section), navArea: section.id)
                    } label: {
                        HStack {
                            Text(NavigationalWarningNavArea(rawValue: section.id)?.description ?? "")
                            Spacer()
                            NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: Array<NavigationalWarning>(section))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                }
                .listRowBackground(Color(scheme.containerScheme.colorScheme.surfaceColor))
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .navigationTitle("Navigational Warnings")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
            .padding(.top, -36)
        }
    }
}

struct NavigationalWarningListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationalWarningListView()
    }
}
