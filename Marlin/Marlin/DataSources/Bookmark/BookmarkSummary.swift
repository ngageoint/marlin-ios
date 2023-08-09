//
//  BookmarkSummary.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkSummary: DataSourceSummaryView {
    var showMoreDetails: Bool = false
    var showTitle: Bool = false
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = true
    var bookmark: Bookmark?
    @State var dataSource: (any DataSource)?
    
    var body: some View {
        Self._printChanges()
        
        return VStack(alignment: .leading) {
            if let dataSource = dataSource as? (any DataSourceViewBuilder) {
                HStack {
                    DataSourceIcon(dataSource: dataSource)
                    Spacer()
                }
                AnyView(
                    dataSource.summary
                        .setShowTitle(true)
                        .setShowSectionHeader(false)
                        .setShowMoreDetails(false)
                        .showBookmarkNotes(showBookmarkNotes)
                )
            }
            
        }
        .task {
            let context = PersistenceController.current.viewContext
            context.perform {
                dataSource = bookmark?.getDataSourceItem(context: PersistenceController.current.viewContext) as? (any DataSource)
            }
        }
    }
}
