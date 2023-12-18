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
    @State var userTrackingModeDescription: String = "none"
    var appearDisabled: Bool {
        !authorized
    }
    @State var showingAlert: Bool = false
    
    var authorized: Bool {
        locationManager.locationStatus == .authorizedAlways || locationManager.locationStatus == .authorizedWhenInUse
    }
    
    @AppStorage("userTrackingMode") var userTrackingMode: Int = Int(MKUserTrackingMode.none.rawValue)
    var mapState: MapState?
    
    init(mapState: MapState?) {
        self.mapState = mapState
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
        .accessibilityElement()
        .accessibilityLabel("Tracking \(userTrackingModeDescription)\(authorized ? "" : " Unauthorized")")
        .onAppear {
            setButtonImage()
            mapState?.userTrackingMode = userTrackingMode
        }
        .onChange(of: locationManager.locationStatus ?? .notDetermined) { newValue in
            setButtonImage()
        }
        .onChange(of: mapState?.userTrackingMode) { newValue in
            if let mode = newValue {
                userTrackingMode = mode
                setButtonImage()
            }
        }
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .secondary,
                size: .mini,
                foregroundColor: appearDisabled ? Color.disabledColor : Color.primaryColorVariant,
                backgroundColor: Color.mapButtonColor))
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Location Services Disabled"),
                  message: Text("""
                    Marlin has been denied access to location services.  To show your location on the map, \
                    please go into your device settings and enable the Location permission.
                  """),
                  primaryButton: .default(Text("Settings"),
                                          action: {
                                                if let url = NSURL(string: UIApplication.openSettingsURLString) as URL? {
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                }
                                          }),
                  secondaryButton: .cancel())
        }
    }
    
    func buttonPressed() {
        if !authorized {
            showingAlert = true
        } else {
            updateTrackingMode()
            setButtonImage()
        }
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
            userTrackingModeDescription = "none"
        case .follow:
            imageName = "location.fill"
            userTrackingModeDescription = "follow"
        case .followWithHeading:
            imageName = "location.north.line.fill"
            userTrackingModeDescription = "follow with heading"
        @unknown default:
            imageName = "location"
            userTrackingModeDescription = "none"
        }
    }
}
