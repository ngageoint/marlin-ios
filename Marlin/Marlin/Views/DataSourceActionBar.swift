//
//  DataSourceActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

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
