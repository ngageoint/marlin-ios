//
//  NavigationalWarningsAreaDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 6/24/22.
//

import Foundation
import Combine

class NavigationalWarningsAreaDataSource: ObservableObject {
    @Published var items = [NavigationalWarning]()
    
    func setNavigationalWarnings(areaWarnings: [NavigationalWarning]) {
        items = areaWarnings
    }
}
