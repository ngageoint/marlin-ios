//
//  ModusViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 1/23/24.
//

import Foundation
import Combine
import SwiftUI

class ModusViewModel: ObservableObject {
    private let trigger = Trigger()

    private enum TriggerId: Hashable {
        case reload
        case loadMore
    }

    enum State {
        case loading
        case loaded(rows: [ModuItem])
        case failure(error: Error)

        fileprivate var rows: [ModuItem] {
            if case let .loaded(rows: rows) = self {
                return rows
            } else {
                return []
            }
        }
    }

    @Published private(set) var state: State = .loading
    @Published var modus: [ModuModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    @Injected(\.moduRepository)
    private var repository: ModuRepository
    var publisher: AnyPublisher<CollectionDifference<ModuModel>, Never>?
    
    init() {
        dataSourceUpdatedPub.store(in: &disposables)
        fetchModus()
    }

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.modu.key
            }
            .sink { _ in
                self.reload()
            }
    }

    func reload() {
        trigger.activate(for: TriggerId.reload)
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }

    func fetchModus(limit: Int = 100) {
        if publisher != nil {
            return
        }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.modus(
                filters: UserDefaults.standard.filter(DataSources.modu),
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
