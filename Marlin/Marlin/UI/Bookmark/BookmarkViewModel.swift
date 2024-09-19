//
//  BookmarkViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation

@MainActor
class BookmarkViewModel: ObservableObject {
    var itemKey: String?
    var dataSource: String?
    @Published var isBookmarked: Bool = false
    @Published var bookmark: BookmarkModel?
    @Published var bookmarkBottomSheet: Bool = false
    @Published var bnotes: String = ""

    @Injected(\.bookmarkRepository)
    private var repository: BookmarkRepository
    
    @discardableResult
    func getBookmark(itemKey: String, dataSource: String) async -> BookmarkModel? {
        self.itemKey = itemKey
        self.dataSource = dataSource
        bookmark = await repository.getBookmark(itemKey: itemKey, dataSource: dataSource)
        self.isBookmarked = bookmark != nil
        return bookmark
    }
    
    func createBookmark(notes: String) {
        Task {
            await repository.createBookmark(
                notes: notes,
                itemKey: self.itemKey ?? "",
                dataSource: self.dataSource ?? ""
            )
            await updateBookmarked()
        }
    }

    func updateBookmarked() async {
        bookmark = await repository.getBookmark(itemKey: self.itemKey ?? "", dataSource: self.dataSource ?? "")
        self.isBookmarked = bookmark != nil
        self.bnotes = bookmark?.notes ?? ""
    }

    func removeBookmark() async {
        guard let itemKey = itemKey, let dataSource = dataSource else {
            return
        }
        _ = await repository.removeBookmark(itemKey: itemKey, dataSource: dataSource)
        await updateBookmarked()
    }
    
    func startBookmarkBottomSheet() async {
        bookmarkBottomSheet = true
    }
}
