//
//  NoticesToMarinersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/21/24.
//

import Foundation
import Combine
import SwiftUI

class NoticesToMarinersViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    @Injected(\.ntmRepository)
    private var repository: NoticeToMarinersRepository
    
    init() {
        dataSourceUpdatedPub.store(in: &disposables)
        fetchNoticeToMarinersSections()
    }
    
    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.noticeToMariners.key
            }
            .sink { _ in
                self.reload()
            }
    }

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [NoticeToMarinersItem])
        case failure(error: Error)

        fileprivate var rows: [NoticeToMarinersItem] {
            if case let .loaded(rows: rows) = self {
                return rows
            } else {
                return []
            }
        }
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

    func fetchNoticeToMarinersSections(limit: Int = 100) {
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            await repository.sectionHeaders(
                filters: UserDefaults.standard.filter(DataSources.noticeToMariners),
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
