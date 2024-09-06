//
//  PortsViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 1/31/24.
//

import Foundation
import Combine
import SwiftUI

class PortsViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var ports: [PortModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    @Injected(\.portRepository)
    private var repository: PortRepository

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.port.key
            }
            .sink { _ in
                self.reload()
            }
    }

    var publisher: AnyPublisher<CollectionDifference<AsamModel>, Never>?

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [PortItem])
        case failure(error: Error)

        fileprivate var rows: [PortItem] {
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
    
    init() {
        dataSourceUpdatedPub.store(in: &disposables)
        fetchPorts()
    }

    func reload() {
        trigger.activate(for: TriggerId.reload)
    }

    func loadMore() {
        trigger.activate(for: TriggerId.loadMore)
    }

    func fetchPorts(limit: Int = 100) {
        if publisher != nil {
            return
        }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.ports(
                filters: UserDefaults.standard.filter(DataSources.port),
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
