//
//  LightsViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import Combine
import SwiftUI

class LightsViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var lights: [LightModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    private var _repository: LightRepository?

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.light.key
            }
            .sink { _ in
                self.reload()
            }
    }

    var repository: LightRepository? {
        get {
            return _repository
        }
        set {
            if _repository == nil {
                dataSourceUpdatedPub.store(in: &disposables)
                _repository = newValue
                fetchLights()
            }
        }
    }

    var publisher: AnyPublisher<CollectionDifference<LightModel>, Never>?

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [LightItem])
        case failure(error: Error)

        fileprivate var rows: [LightItem] {
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

    func fetchLights(limit: Int = 100) {
        if publisher != nil {
            return
        }
        guard let repository = _repository else { return }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.lights(
                filters: UserDefaults.standard.filter(DataSources.asam),
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
