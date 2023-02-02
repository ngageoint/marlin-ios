//
//  MarlinUserDefaults.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import Foundation
import MapKit

extension UserDefaults {
    
    static func registerMarlinDefaults() {
        if let path = Bundle.main.path(forResource: "userDefaults", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            UserDefaults.standard.register(defaults: dict)
        }
        
        if let path = Bundle.main.path(forResource: "appFeatures", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject] {
            UserDefaults.standard.register(defaults: dict)
        }
    }
    
    @objc func mkcoordinateregion(forKey key: String) -> MKCoordinateRegion {
        if let regionData = array(forKey: key) as? [Double] {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: regionData[0], longitude: regionData[1]), latitudinalMeters: regionData[2], longitudinalMeters: regionData[3]);
        }
        return MKCoordinateRegion(center: kCLLocationCoordinate2DInvalid, span: MKCoordinateSpan(latitudeDelta: -1, longitudeDelta: -1));
    }
    
    func setRegion(_ value: MKCoordinateRegion, forKey key: String) {
        let span = value.span
        let center = value.center
        
        let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
        let loc3 = CLLocation(latitude: center.latitude, longitude: center.longitude - span.longitudeDelta * 0.5)
        let loc4 = CLLocation(latitude: center.latitude, longitude: center.longitude + span.longitudeDelta * 0.5)
        
        let metersInLatitude = loc1.distance(from: loc2)
        let metersInLongitude = loc3.distance(from: loc4)
        
        let regionData: [Double] = [value.center.latitude, value.center.longitude, metersInLatitude, metersInLongitude];
        setValue(regionData, forKey: key);
    }
    
    func showOnMap(key: String) -> Bool {
        bool(forKey: "showOnMap\(key)")
    }
    
    @objc var showOnMapmodu: Bool {
        bool(forKey: "showOnMap\(Modu.key)")
    }
    
    @objc var showOnMapasam: Bool {
        bool(forKey: "showOnMap\(Asam.key)")
    }
    
    @objc var showOnMaplight: Bool {
        bool(forKey: "showOnMap\(Light.key)")
    }
    
    @objc var showOnMapport: Bool {
        bool(forKey: "showOnMap\(Port.key)")
    }
    
    @objc var showOnMapradioBeacon: Bool {
        bool(forKey: "showOnMap\(RadioBeacon.key)")
    }
    
    @objc var showOnMapdifferentialGPSStation: Bool {
        bool(forKey: "showOnMap\(DifferentialGPSStation.key)")
    }
    
    @objc var showOnMapdfrs: Bool {
        bool(forKey: "showOnMap\(DFRS.key)")
    }

    @objc var mapRegion: MKCoordinateRegion {
        get {
            return mkcoordinateregion(forKey: #function)
        }
        set {
            setRegion(newValue, forKey: #function)
        }
    }
    
    @objc var actualRangeLights: Bool {
        get {
            bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }
    
    @objc var actualRangeSectorLights: Bool {
        get {
            bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
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
    
    @objc var asamFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var moduFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var portFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var radioBeaconFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var differentialGPSStationFilter: Data? {
        data(forKey: #function)
    }
    @objc var dfrsFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var lightFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var epubFilter: Data? {
        data(forKey: #function)
    }
    
    @objc var ntmFilter: Data? {
        data(forKey: #function)
    }
    
    func filter(_ dataSource: any DataSource.Type) -> [DataSourceFilterParameter] {
        if let data = data(forKey: "\(dataSource.key)Filter") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let filter = try decoder.decode([DataSourceFilterParameter].self, from: data)

                return filter
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        
        return dataSource.defaultFilter
    }
    
    func setFilter(_ key: String, filter: [DataSourceFilterParameter]) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            let data = try encoder.encode(filter)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "\(key)Filter")
            NotificationCenter.default.post(name: .DataSourceUpdated, object: key)
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    @objc var asamSort: Data? {
        data(forKey: #function)
    }
    
    @objc var moduSort: Data? {
        data(forKey: #function)
    }
    
    @objc var portSort: Data? {
        data(forKey: #function)
    }
    
    @objc var radioBeaconSort: Data? {
        data(forKey: #function)
    }
    
    @objc var differentialGPSStationSort: Data? {
        data(forKey: #function)
    }
    
    @objc var dfrsSort: Data? {
        data(forKey: #function)
    }
    
    @objc var ntmSort: Data? {
        data(forKey: #function)
    }
    
    @objc var lightSort: Data? {
        data(forKey: #function)
    }
    
    @objc var epubSort: Data? {
        data(forKey: #function)
    }
    
    func sort(_ key: String) -> [DataSourceSortParameter] {
        if let data = data(forKey: "\(key)Sort") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let sort = try decoder.decode([DataSourceSortParameter].self, from: data)
                
                return sort
            } catch {
                print("Unable to Decode sort (\(error))")
            }
        }
        return []
    }
    
    func setSort(_ key: String, sort: [DataSourceSortParameter]) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()
            
            // Encode Note
            let data = try encoder.encode(sort)
            
            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "\(key)Sort")
            NotificationCenter.default.post(name: .DataSourceUpdated, object: key)
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
    
    // MARK: App features
    var hamburger: Bool {
        bool(forKey: "hamburger")
    }
    
    var metricsEnabled: Bool {
        bool(forKey: #function)
    }
    
    func dataSourceEnabled(_ dataSource: any DataSource.Type) -> Bool {
        bool(forKey: "\(dataSource.key)DataSourceEnabled")
    }
    
    func lastSyncTimeSeconds(_ dataSource: any DataSource.Type) -> Double {
        return double(forKey: "\(dataSource.key)LastSyncTime")
    }
    
    func updateLastSyncTimeSeconds(_ dataSource: any BatchImportable.Type) {
        setValue(Date().timeIntervalSince1970, forKey: "\(dataSource.key)LastSyncTime")
    }
    
    func clearLastSyncTimeSeconds(_ dataSource: any BatchImportable.Type) {
        removeObject(forKey: "\(dataSource.key)LastSyncTime")
    }
}
