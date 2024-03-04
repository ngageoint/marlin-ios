//
//  BookmarkListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/23.
//

import SwiftUI

struct BookmarkListView: View {
    @EnvironmentObject var repository: BookmarkRepository
    @StateObject var viewModel: BookmarksViewModel = BookmarksViewModel()

    @EnvironmentObject var router: MarlinRouter

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        MultiImageContainerView(visibleImage: "bookmark", maskingImage: "bookmark.fill")
                            .frame(maxHeight: 300)
                            .padding([.trailing, .leading], 24)
                            .foregroundColor(Color.onSurfaceColor)
                        Spacer()
                    }
                    Text("Loading Bookmarks")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    ProgressView()
                        .tint(Color.primaryColorVariant)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundColor)
                .transition(AnyTransition.opacity)
            case let .loaded(rows: rows):
                ZStack(alignment: .bottomTrailing) {
                    List(rows) { bookmarkItem in
                        switch bookmarkItem {
                        case .listItem(let bookmark):
                            BookmarkSummary(bookmark: bookmark)
                                .paddedCard()
                                .onAppear {
                                    if rows.last == bookmarkItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.backgroundColor)
                        case .sectionHeader(let header):
                            Text(header)
                                .onAppear {
                                    if rows.last == bookmarkItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .sectionHeader()
                        }

                    }
                    .listStyle(.plain)
                    .listSectionSeparator(.hidden)
                    .refreshable {
                        viewModel.reload()
                    }
                }
                .emptyPlaceholder(rows) {
                    BookmarkListEmptyState()
                }
                .transition(AnyTransition.opacity)
            case let .failure(error: error):
                Text(error.localizedDescription)
            }
        }
        .navigationTitle(DataSources.bookmark.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            viewModel.repository = repository
            Metrics.shared.dataSourceList(dataSource: DataSources.bookmark)
        }
    }
}
