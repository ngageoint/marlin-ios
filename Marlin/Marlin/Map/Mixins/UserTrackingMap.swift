//
//  UserTrackingMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/29/22.
//

import Foundation
import MapKit
import MaterialComponents

class UserTrackingMap: NSObject, MapMixin {
    var mapView: MKMapView?
    var scheme: MarlinScheme?
    var indexInView: Int = 0
    var locationManager: CLLocationManager?
    var isTrackingAnimation: Bool = false
    var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private lazy var trackingButton: MDCFloatingButton = {
        let trackingButton = MDCFloatingButton(shape: .mini)
        trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        trackingButton.addTarget(self, action: #selector(onTrackingButtonPressed(_:)), for: .touchUpInside)
        trackingButton.accessibilityLabel = "track location"
        return trackingButton
    }()
    
    init(locationManager: CLLocationManager? = CLLocationManager()) {
        self.locationManager = locationManager
    }
    
    func cleanupMixin() {
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    func applyTheme(scheme: MarlinScheme?) {
        guard let scheme = scheme else {
            return
        }
        self.scheme = scheme
        
        trackingButton.backgroundColor = scheme.containerScheme.colorScheme.surfaceColor;
        trackingButton.tintColor = scheme.containerScheme.colorScheme.primaryColorVariant;
        self.trackingButton.setImageTintColor(scheme.containerScheme.colorScheme.primaryColorVariant, for: .normal)
    }
    
    func setupMixin(mapView: MKMapView, marlinMap: MarlinMap, scheme: MarlinScheme? = nil) {
        self.mapView = mapView

        if marlinMap.mutatingWrapper.lowerRightButtonStack.arrangedSubviews.count < indexInView {
            marlinMap.mutatingWrapper.lowerRightButtonStack.insertArrangedSubview(trackingButton, at: marlinMap.mutatingWrapper.lowerRightButtonStack.arrangedSubviews.count)
        } else {
            marlinMap.mutatingWrapper.lowerRightButtonStack.insertArrangedSubview(trackingButton, at: indexInView)
        }
        
        self.applyTheme(scheme: scheme)
        
        locationManager?.delegate = self
        
        setupTrackingButton()
    }
    
    @objc func onTrackingButtonPressed(_ sender: UIButton) {
        let authorized = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
        if !authorized {
            let alert = UIAlertController(title: "Location Services Disabled", message: "Marlin has been denied access to location services.  To show your location on the map, please go into your device settings and enable the Location permission.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                if let url = NSURL(string: UIApplication.openSettingsURLString) as URL? {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let mapView = mapView else {
            return
        }
        
        switch mapView.userTrackingMode {
        case .none:
            mapView.setUserTrackingMode(.follow, animated: true)
            trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        case .follow:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            trackingButton.setImage(UIImage(systemName: "location.north.line.fill"), for: .normal)
        case .followWithHeading:
            mapView.setUserTrackingMode(.none, animated: true)
            trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        @unknown default:
            mapView.setUserTrackingMode(.none, animated: true)
            trackingButton.setImage(UIImage(systemName: "location"), for: .normal)
        }
    }
    
    func setupTrackingButton() {
        let authorized = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
        guard let scheme = scheme else {
            return
        }
        if !authorized {
            trackingButton.applySecondaryTheme(withScheme: scheme.disabledScheme)
        } else {
            self.trackingButton.backgroundColor = scheme.containerScheme.colorScheme.surfaceColor;
            self.trackingButton.tintColor = scheme.containerScheme.colorScheme.primaryColorVariant;
            self.trackingButton.setImageTintColor(scheme.containerScheme.colorScheme.primaryColorVariant, for: .normal)
        }
    }
}

extension UserTrackingMap: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationAuthorizationStatus = manager.authorizationStatus
        setupTrackingButton()
    }
}
