//
//  DataSourceWindowUnits.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import Foundation

enum DataSourceWindowUnits: String, CaseIterable, Identifiable, Codable {
    case last30Days = "last 30 days"
    case last7Days = "last 7 days"
    case last90Days = "last 90 days"
    case last365Days = "last 365 days"
    
    var id: String { rawValue }
    
    func numberOfDays() -> Int {
        switch (self) {
        case .last7Days:
            return 7
        case .last30Days:
            return 30
        case .last90Days:
            return 90
        case .last365Days:
            return 365
        }
    }
}
