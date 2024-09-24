//
//  BookmarksViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 3/4/24.
//

import Foundation
import Combine
import SwiftUI

class BookmarksViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var bookmarks: [BookmarkModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    @Injected(\.bookmarkRepository)
    private var repository: BookmarkRepository

    var publisher: AnyPublisher<CollectionDifference<BookmarkModel>, Never>?

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [BookmarkItem])
        case failure(error: Error)

        fileprivate var rows: [BookmarkItem] {
            if case let .loaded(rows: rows) = self {
                return rows
            } else {
                return []
            }
        }
    }
    
    init() {
        fetchBookmarks()
        repository.refreshPublisher.sink { [weak self] _ in
            self?.reload()
        }
        .store(in: &disposables)
    }

    private enum TriggerId: Hashable {
        case reload
        case loadMore
    }

    func reload() {
        trigger.activate(for: TriggerId.reload)
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }

    func fetchBookmarks(limit: Int = 100) {
        if publisher != nil {
            return
        }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.bookmarks(
                filters: UserDefaults.standard.filter(DataSources.bookmark),
                paginatedBy: trigger.signal(activatedBy: TriggerId.loadMore)
            )
            .scan([]) { $0 + $1 }
            .map { State.loaded(rows: $0) }
            .catch { error in
                return Just(State.failure(error: error))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] recieve in
            guard let self = self else { return }
            switch(self.state, recieve) {
            case (.loaded, .loaded):
                self.state = recieve
            default:
                withAnimation(.easeIn(duration: 1.0)) {
                    self.state = recieve
                }
            }
        }
        .store(in: &disposables)
    }
}
