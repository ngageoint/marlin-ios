//
//  TestHelper.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/6/22.
//

import Foundation
import UIKit
import CoreLocation

@testable import Marlin

class TestHelpers {
    let scheme = MarlinScheme()
    
    public static func createGradientImage(startColor: UIColor, endColor: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
    
    public static func getKeyWindowVisible() -> UIWindow {
        guard let window = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .systemBackground
            window.makeKeyAndVisible()
            print("This is the window \(window)")
            return window
        }
        
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        print("This is the window \(window)")
        return window
    }
    
    public static func getAllAccessibilityLabels(_ viewRoot: UIView) -> [String]! {
        var array = [String]()
        for view in viewRoot.subviews {
            if let lbl = view.accessibilityLabel {
                array += [lbl]
            }
            
            array += getAllAccessibilityLabels(view)
        }
        
        return array
    }
    
    public static func getAllAccessibilityLabelsInWindows() -> [String]! {
        var labelArray = [String]()
        for  window in UIApplication.shared.windowsWithKeyWindow() {
            print("window \(window)")
            labelArray += getAllAccessibilityLabels(window as! UIWindow )
        }
        
        return labelArray
    }
    
    public static func printAllAccessibilityLabelsInWindows() {
        let labelArray = TestHelpers.getAllAccessibilityLabelsInWindows();
        NSLog("labelArray = \(labelArray ?? [])")
    }
    
    static func clearData() {
//        let asamsTruncated = PersistenceController.shared.container.viewContext.truncateAll(Asam.self)
//        print("Asams truncated? \(asamsTruncated)")
//        let modusTruncated = PersistenceController.shared.container.viewContext.truncateAll(Modu.self)
//        print("Modus truncated? \(modusTruncated)")
//        let navigationalWarningsTruncated = PersistenceController.shared.container.viewContext.truncateAll(NavigationalWarning.self)
//        print("Navigational Warnings truncated? \(navigationalWarningsTruncated)")
//        let lightsTruncated = PersistenceController.shared.container.viewContext.truncateAll(Light.self)
//        print("Lights truncated? \(lightsTruncated)")
    }
}

class MockLocationManager: LocationManager {
//    @Published override var locationStatus: CLAuthorizationStatus?
    public var requestAuthorizationCalled = false
    override func requestAuthorization() {
        requestAuthorizationCalled = true
        NotificationCenter.default.post(Notification(name: .LocationAuthorizationStatusChanged, object: CLAuthorizationStatus.authorizedAlways))
    }
    
    override func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    override internal init(locationManager: CLLocationManager) {
        super.init(locationManager: locationManager)
    }
}

class MockCLLocationManager: CLLocationManager {
    public var requestAuthorizationCalled = false
    public var overriddenAuthStatus: CLAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: CLAuthorizationStatus {
        return overriddenAuthStatus
    }
    
    override func requestWhenInUseAuthorization() {
        requestAuthorizationCalled = true
        print("xxx request called")
    }
    
    override func startUpdatingHeading() {
        
    }
    
    override func startUpdatingLocation() {
        
    }
}
