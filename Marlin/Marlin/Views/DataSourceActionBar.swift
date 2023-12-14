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
    var bookmark: AsamActions.Bookmark?
    
    var body: some View {
        HStack(spacing:0) {
            if let moreDetails = moreDetails {
                MoreDetailsButton2(action: moreDetails)
                    .buttonStyle(MaterialButtonStyle())
            }
            
            if let location = location {
                CoordinateButton2(action: location)
                    .buttonStyle(MaterialButtonStyle())
            }
            
            Spacer()
            
            if let bookmark = bookmark {
                BookmarkButton2(action: bookmark)
                    .buttonStyle(MaterialButtonStyle())
            }

            if let zoom = zoom {
                FocusButton2(action: zoom)
                    .buttonStyle(MaterialButtonStyle())
            }
        }
    }
}

struct DataSourceActionBar: View {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager

    var data: any DataSource
    var showMoreDetailsButton = false
    var showFocusButton = true
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    
    var body: some View {
        HStack(spacing:0) {
            if showMoreDetailsButton {
                MoreDetailsButton(data: data)
            } else if let data = data as? Locatable {
                CoordinateButton(coordinate: data.coordinate)
            }
            
            Spacer()
            Group {
                if let bookmarkable = data as? Bookmarkable, bookmarkable.canBookmark {
                    BookmarkButton(viewModel: bookmarkViewModel)
                }
                if let data = data as? CustomStringConvertible {
                    ShareButton(shareText: data.description, dataSource: data as? (any DataSourceViewBuilder))
                }
                if showFocusButton {
                    FocusButton(data: data)
                }
            }.padding(.trailing, -8)
        }
        .buttonStyle(MaterialButtonStyle())
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            if let bookmarkable = data as? Bookmarkable {
                bookmarkViewModel.getBookmark(itemKey: bookmarkable.itemKey, dataSource: bookmarkable.key)
            }
        }
    }
}
