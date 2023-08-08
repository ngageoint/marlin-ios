//
//  DataSourceActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct DataSourceActionBar: View {
    var data: DataSource & CustomStringConvertible
    var showMoreDetailsButton = false
    var showFocusButton = true
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                MoreDetailsButton(data: data)
            } else if let data = data as? DataSourceLocation {
                CoordinateButton(coordinate: data.coordinate)
            }
            
            Spacer()
            Group {
                if let bookmarkable = data as? Bookmarkable, let itemKey = bookmarkable.itemKey {
                    BookmarkButton(viewModel: BookmarkViewModel(itemKey: itemKey, dataSource: bookmarkable.key))
                }
                ShareButton(shareText: data.description, dataSource: data as? (any DataSourceViewBuilder))
                if showFocusButton {
                    FocusButton(data: data)
                }
            }.padding(.trailing, -8)
        }
        .buttonStyle(MaterialButtonStyle())
    }
}
