//
//  MarlinUserDefaults.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation

extension UserDefaults {
    
    static func registerMarlinDefaults() {
        if let path = Bundle.main.path(forResource: "userDefaults", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            UserDefaults.standard.register(defaults: dict)
        }
    }
    
    @objc var showOnMapModu: Bool {
        bool(forKey: "showOnMapModu")
    }
    
    @objc var showOnMapAsam: Bool {
        bool(forKey: "showOnMapAsam")
    }

}
