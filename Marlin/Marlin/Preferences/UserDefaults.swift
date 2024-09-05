//
//  UserDefaults.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

extension UserDefaults {
    var hamburger: Bool {
        bool(forKey: "hamburger")
    }

    var showUnparsedNavigationalWarnings: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }

    var metricsEnabled: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }

    func dataSourceEnabled(_ dataSource: any DataSourceDefinition) -> Bool {
        bool(forKey: "\(dataSource.key)DataSourceEnabled")
    }
}
