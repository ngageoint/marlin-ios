//
//  RadioBeaconsViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/24.
//

import Foundation
import Combine
import SwiftUI

class RadioBeaconsViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var radioBeacons: [RadioBeaconModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    private var _repository: RadioBeaconRepository?

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.radioBeacon.key
            }
            .sink { _ in
                self.reload()
            }
    }

    var repository: RadioBeaconRepository? {
        get {
            return _repository
        }
        set {
            if _repository == nil {
                dataSourceUpdatedPub.store(in: &disposables)
                _repository = newValue
                fetchRadioBeacons()
            }
        }
    }

    var publisher: AnyPublisher<CollectionDifference<RadioBeaconModel>, Never>?

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [RadioBeaconItem])
        case failure(error: Error)

        fileprivate var rows: [RadioBeaconItem] {
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

    func fetchRadioBeacons(limit: Int = 100) {
        if publisher != nil {
            return
        }
        guard let repository = _repository else { return }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.radioBeacons(
                filters: UserDefaults.standard.filter(DataSources.radioBeacon),
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
