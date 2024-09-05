//
//  MarlinUserDefaults.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation
import MapKit
import Combine

extension UserDefaults {
    
    static func registerMarlinDefaults() {
        if let path = Bundle.main.path(
            forResource: "userDefaults",
            ofType: "plist"
        ), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            UserDefaults.standard.register(defaults: dict)
        }
        
        if let path = Bundle.main.path(
            forResource: "appFeatures",
            ofType: "plist"
        ), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            UserDefaults.standard.register(defaults: dict)
        }
    }
    
    @objc var initialDataLoaded: Bool {
        get {
            bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }
    
    @objc var lastLoadDate: Date {
        get {
            return Date(timeIntervalSince1970: double(forKey: #function))
        }
        set {
            setValue(newValue.timeIntervalSince1970, forKey: #function)
        }
    }
    
    var forceReloadDate: Date? {
        return object(forKey: #function) as? Date
    }
    
    func imageScale(_ key: String) -> CGFloat? {
        if let size = object(forKey: "\(key)ImageScale") as? Float {
            return CGFloat(size)
        }
        return nil
    }
    
    @objc var userTabs: Int {
        get {
            return integer(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }

    var searchType: SearchType {
        get {
            return SearchType.init(rawValue: integer(forKey: #function)) ?? .native
        }
        set {
            setValue(newValue.rawValue, forKey: #function)
        }
    }
}
