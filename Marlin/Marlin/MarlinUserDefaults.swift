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
    
    @objc var showOnMapModu: Bool {
        bool(forKey: "showOnMapModu")
    }
    
    @objc var showOnMapAsam: Bool {
        bool(forKey: "showOnMapAsam")
    }
    
    @objc var showOnMapLights: Bool {
        bool(forKey: "showOnMapLights")
    }

    @objc var mapRegion: MKCoordinateRegion {
        get {
            return mkcoordinateregion(forKey: #function)
        }
        set {
            setRegion(newValue, forKey: #function)
        }
    }
}
