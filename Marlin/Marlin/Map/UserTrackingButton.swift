//
//  UserTrackingButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/22.
//

import SwiftUI
import MapKit

struct UserTrackingButton: View {
    @EnvironmentObject var locationManager: LocationManager

    @State var imageName: String = "location"
    @State var appearDisabled: Bool = false
    
    @AppStorage("userTrackingMode") var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    var mapState: MapState?
    
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
        .onAppear {
            setupTrackingButton(locationAuthorizationStatus: locationManager.locationStatus ?? .notDetermined)
            mapState?.userTrackingMode = userTrackingMode
        }
        .onChange(of: locationManager.locationStatus ?? .notDetermined) { newValue in
            setupTrackingButton(locationAuthorizationStatus: newValue)
        }
        .onChange(of: mapState?.userTrackingMode) { newValue in
            if let mode = newValue {
                userTrackingMode = mode
                setButtonImage()
            }
        }
        .buttonStyle(MaterialFloatingButtonStyle(type: .secondary, size: .mini))
    }
    
    func buttonPressed() {
        let authorized = locationManager.locationStatus == .authorizedAlways || locationManager.locationStatus == .authorizedWhenInUse
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
        
        updateTrackingMode()
        setButtonImage()
    }
    
    func setupTrackingButton(locationAuthorizationStatus: CLAuthorizationStatus) {
        let authorized = locationAuthorizationStatus == .authorizedAlways || locationAuthorizationStatus == .authorizedWhenInUse
        appearDisabled = !authorized
        
        setButtonImage()
    }
    
    func updateTrackingMode() {
        switch MKUserTrackingMode(rawValue: userTrackingMode) ?? .none {
        case .none:
            userTrackingMode = MKUserTrackingMode.follow.rawValue
        case .follow:
            userTrackingMode = MKUserTrackingMode.followWithHeading.rawValue
        case .followWithHeading:
            userTrackingMode = MKUserTrackingMode.none.rawValue
        @unknown default:
            userTrackingMode = MKUserTrackingMode.none.rawValue
        }
        DispatchQueue.main.async {
            mapState?.userTrackingMode = userTrackingMode
        }
    }
    
    func setButtonImage() {
        switch MKUserTrackingMode(rawValue: userTrackingMode) ?? .none {
        case .none:
            imageName = "location"
        case .follow:
            imageName = "location.fill"
        case .followWithHeading:
            imageName = "location.north.line.fill"
        @unknown default:
            imageName = "location"
        }
    }
}
