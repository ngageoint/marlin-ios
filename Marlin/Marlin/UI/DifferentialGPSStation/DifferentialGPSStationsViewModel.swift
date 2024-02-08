//
//  DifferentialGPSStationsViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import Combine
import SwiftUI

class DifferentialGPSStationsViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var differentialGPSStations: [DifferentialGPSStationModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    private var _repository: DifferentialGPSStationRepository?

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.dgps.key
            }
            .sink { _ in
                self.reload()
            }
    }

    var repository: DifferentialGPSStationRepository? {
        get {
            return _repository
        }
        set {
            if _repository == nil {
                _repository = newValue
                fetchDifferentialGPSStations()
            }
        }
    }

    var publisher: AnyPublisher<CollectionDifference<DifferentialGPSStationModel>, Never>?

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [DifferentialGPSStationItem])
        case failure(error: Error)

        fileprivate var rows: [DifferentialGPSStationItem] {
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

    func fetchDifferentialGPSStations(limit: Int = 100) {
        if publisher != nil {
            return
        }
        guard let repository = _repository else { return }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.dgps(
                filters: UserDefaults.standard.filter(DataSources.dgps),
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
