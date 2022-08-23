//
//  UserTrackingButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/22.
//

import SwiftUI
import MapKit

struct UserTrackingButton: View {    
    @State var imageName: String = "location"
    @State var appearDisabled: Bool = false
    @ObservedObject var coordinator: Coordinator
    
    @AppStorage("userTrackingMode") var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    
    init() {
        self.coordinator = Coordinator()
        coordinator.setDelegate()
    }

    var body: some View {
        Button(action: {
            buttonPressed()
        }) {
            Label(
                title: {},
                icon: { Image(systemName: imageName)
                        .renderingMode(.template)
                })
        }
        .onReceive(coordinator.$locationAuthorizationStatus) { status in
            setupTrackingButton(locationAuthorizationStatus: status)
        }
        .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini))
    }
    
    func buttonPressed() {
        let authorized = coordinator.locationAuthorizationStatus == .authorizedAlways || coordinator.locationAuthorizationStatus == .authorizedWhenInUse
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
        switch MKUserTrackingMode(rawValue: userTrackingMode) ?? .none {
        case .none:
            userTrackingMode = MKUserTrackingMode.follow.rawValue
            imageName = "location.fill"
        case .follow:
            userTrackingMode = MKUserTrackingMode.followWithHeading.rawValue
            imageName = "location.north.line.fill"
        case .followWithHeading:
            userTrackingMode = MKUserTrackingMode.none.rawValue
            imageName = "location"
        @unknown default:
            userTrackingMode = MKUserTrackingMode.none.rawValue
            imageName = "location"
        }
    }
    
    func setupTrackingButton(locationAuthorizationStatus: CLAuthorizationStatus) {
        let authorized = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
        appearDisabled = !authorized
    }
    
    class Coordinator: NSObject, ObservableObject, CLLocationManagerDelegate {
        @Published var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
        var locationManager: CLLocationManager?
        
        func setDelegate() {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
        }
        
        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            locationAuthorizationStatus = manager.authorizationStatus
        }
    }
}
