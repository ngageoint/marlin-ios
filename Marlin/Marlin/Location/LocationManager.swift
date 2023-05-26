//
//  LocationManager.swift
//  Marlin
//
//  Created by Daniel Barela on 7/19/22.
//

import Foundation
import CoreLocation
import Combine
import sf_proj_ios
import geopackage_ios
import mgrs_ios
import ExceptionCatcher
import SwiftUI

//private struct LocationManagerKey: EnvironmentKey {
//    typealias Value = LocationManagerProtocol
//    
//    static let defaultValue: any Value = EmptyLocationManager.shared
//}
//
//private struct LastLocationKey: EnvironmentKey {
//    static let defaultValue: CLLocation? = nil
//}
//
//extension EnvironmentValues {
//    var locationManager: any LocationManagerProtocol {
//        get { self[LocationManagerKey.self] }
//        set { self[LocationManagerKey.self] = newValue }
//    }
//    
//    var lastLocation: CLLocation? {
//        get { self[LastLocationKey.self] }
//        set { self[LastLocationKey.self] = newValue }
//    }
//}
//
//extension View {
//    func lastLocation(_ lastLocation: CLLocation?) -> some View {
//        environment(\.lastLocation, lastLocation)
//    }
//    func locationManager(_ locationManager: any LocationManagerProtocol) -> some View {
//        environment(\.locationManager, locationManager)
//    }
//}

protocol LocationManagerProtocol: ObservableObject {
    var lastLocation: CLLocation? { get set }
    var currentNavArea: NavigationalWarningNavArea? { get set }
    var locationStatus: CLAuthorizationStatus? { get set }
    func requestAuthorization()
}

//class EmptyLocationManager: NSObject, ObservableObject, LocationManagerProtocol {
//    static let shared = EmptyLocationManager()
//
//    private override init() {
//        super.init()
//    }
//
//    var lastLocation: CLLocation?
//
//    var currentNavArea: NavigationalWarningNavArea?
//
//    var locationStatus: CLAuthorizationStatus?
//
//    func requestAuthorization() { }
//}

class LocationManager: NSObject, ObservableObject, LocationManagerProtocol, CLLocationManagerDelegate {
    static var _shared: LocationManager?

    class func shared(locationManager: CLLocationManager? = nil) -> LocationManager {
        if let _shared = _shared {
            return _shared
        }
        _shared = LocationManager(locationManager: locationManager ?? CLLocationManager())
        return _shared!
    }
    
    var locationManager: CLLocationManager?
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var currentNavArea: NavigationalWarningNavArea?
    @Published var current10kmMGRS: String?
    
    let navAreaGeoPackageFileName = "navigation_areas"
    let navAreaGeoPackageTableName = "navigation_areas"
    var navAreaGeoPackage: GPKGGeoPackage?
    var navAreaFeatureDao: GPKGFeatureDao?
    
    private init(locationManager: CLLocationManager) {
        super.init()
        self.locationManager = locationManager
        self.locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager?.distanceFilter = 10
        self.locationManager?.delegate = self
        initializeGeoPackage()
    }
    
    func requestAuthorization() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func initializeGeoPackage() {
        guard let manager = GPKGGeoPackageFactory.manager() else {
            return
        }
        let geoPackagePath = Bundle.main.path(forResource: navAreaGeoPackageFileName, ofType: "gpkg")
        if !manager.exists(navAreaGeoPackageFileName) {
            do {
                let imported = try ExceptionCatcher.catch {
                    return manager.importGeoPackage(fromPath: geoPackagePath)
                }
                if !imported {
                    return
                }
            } catch {
                print("Error:", error.localizedDescription)
                // probably was already imported, just ignore
            }
        }
        
        navAreaGeoPackage = manager.open(navAreaGeoPackageFileName)
        navAreaFeatureDao = navAreaGeoPackage?.featureDao(withTableName: navAreaGeoPackageTableName)
    }
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        NotificationCenter.default.post(Notification(name: .LocationAuthorizationStatusChanged, object: status))
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            DispatchQueue.main.async {
                self.locationManager?.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        updateArea()
    }
    
    func updateCurrentNavArea() {
        guard let navAreaFeatureDao = navAreaFeatureDao, let navAreaGeoPackage = navAreaGeoPackage, let lastLocation = lastLocation else {
            return
        }
        let rtree = GPKGRTreeIndexExtension(geoPackage: navAreaGeoPackage)
        let rtreeDao = rtree?.tableDao(with: navAreaFeatureDao)
        guard let point = SFPoint(xValue: lastLocation.coordinate.longitude, andYValue: lastLocation.coordinate.latitude), let resultSet = rtreeDao?.queryFeatures(with: point.envelope()) else {
            return
        }
        if resultSet.moveToNext() {
            if let code = resultSet.row().value(withColumn: "code") as? String {
                currentNavArea = NavigationalWarningNavArea.fromId(id: code)
            }
        }
        resultSet.close()
    }
    
    func updateArea() {
        guard let lastLocation = lastLocation else {
            return
        }
        let mgrsPosition = MGRS.from(lastLocation.coordinate.longitude, lastLocation.coordinate.latitude)
        let mgrsZone = mgrsPosition.coordinate(.TEN_KILOMETER)
        if current10kmMGRS != mgrsZone {
            current10kmMGRS = mgrsZone
            updateCurrentNavArea()
        }
    }
}
