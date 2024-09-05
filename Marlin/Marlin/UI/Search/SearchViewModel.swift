//
//  SearchViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 3/11/24.
//

import Foundation
import MapKit

class SearchViewModel: ObservableObject, Identifiable {
    @Published var searchResult: SearchResultModel?

    var id: String?

    init(id: String? = nil) {
        self.id = id
    }

    var repository: SearchRepository? {
        didSet {
            if let id = id {
                getItem(id: id)
            }
        }
    }

    @discardableResult
    func getItem(id: String) -> SearchResultModel? {
        searchResult = repository?.getResult(id: id)
        return searchResult
    }
}
