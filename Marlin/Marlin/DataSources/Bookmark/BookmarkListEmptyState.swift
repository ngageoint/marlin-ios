//
//  BookmarkListEmptyState.swift
//  Marlin
//
//  Created by Daniel Barela on 8/4/23.
//

import SwiftUI

struct BookmarkListEmptyState: View {
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                HStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Image(systemName: "bookmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geo.size.width / 2.0, maxHeight: geo.size.width / 2.0)
                                .opacity(0.87)
                                .offset(x: min(geo.size.width, geo.size.height) / 20.0, y: -(min(geo.size.width, geo.size.height) / 20.0))
                                .foregroundColor(Color.onSurfaceColor)
                            Image(systemName: "bookmark.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geo.size.width / 2.0, maxHeight: geo.size.width / 2.0)
                                .foregroundColor(Color.backgroundColor)
                            Image(systemName: "bookmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: geo.size.width / 2.0, maxHeight: geo.size.width / 2.0)
                                .foregroundColor(Color.onSurfaceColor)
                                .opacity(0.87)
                        }
                        Spacer()
                    }
                }
                .padding(24)
                Text("No Bookmarks")
                    .font(.headline5)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .opacity(0.94)
                Text("Bookmark an item and it will show up here.")
                    .font(.headline6)
                    .opacity(0.87)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                Spacer()
                
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
