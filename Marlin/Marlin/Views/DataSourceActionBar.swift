//
//  DataSourceActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct DataSourceActions: View {
    var moreDetails: Action?
    var location: Actions.Location?
    var zoom: Action?
    var bookmark: Actions.Bookmark?
    var share: String?
    
    var body: some View {
        HStack(spacing: 0) {
            if let moreDetails = moreDetails {
                MoreDetailsButton(action: moreDetails)
                    .buttonStyle(MaterialButtonStyle())
            }
            
            if let location = location {
                CoordinateButton(action: location)
                    .buttonStyle(MaterialButtonStyle())
            }
            
            Spacer()
            
            if let bookmark = bookmark {
                BookmarkButton(action: bookmark)
                    .buttonStyle(MaterialButtonStyle())
            }

            if let share = share {
                ShareButton(shareText: share, dataSource: Asam.self as? (any DataSource))
            }

            if let zoom = zoom {
                FocusButton(action: zoom)
                    .buttonStyle(MaterialButtonStyle())
            }
        }
    }
}
