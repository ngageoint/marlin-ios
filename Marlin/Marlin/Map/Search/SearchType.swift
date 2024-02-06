//
//  SearchType.swift
//  Marlin
//
//  Created by Joshua Nelson on 2/5/24.
//

enum SearchType: Int, CustomStringConvertible {
    case native, nominatim
    
    var description: String {
        switch self {
        case .native:
            return "Apple Maps"
        case .nominatim:
            return "Nominatim"
        }
    }
}
