//
//  UserPlacesViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 3/4/24.
//

import Foundation
import Combine
import SwiftUI

class UserPlacesViewModel: ObservableObject {
    @Published private(set) var state: State = .loading
    @Published var userPlaces: [UserPlaceModel] = []
    @Published var loaded: Bool = false
    private var disposables = Set<AnyCancellable>()

    var repository: UserPlaceRepository? {
        didSet {
            fetchUserPlaces()
        }
    }

    private let trigger = Trigger()

    enum State {
        case loading
        case loaded(rows: [UserPlaceItem])
        case failure(error: Error)

        fileprivate var rows: [UserPlaceItem] {
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

    func fetchUserPlaces(limit: Int = 100) {
        guard let repository = repository else { return }
        Publishers.PublishAndRepeat(
            onOutputFrom: trigger.signal(activatedBy: TriggerId.reload)
        ) { [trigger, repository] in
            repository.userPlaces(
                filters: UserDefaults.standard.filter(DataSources.userPlace),
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
