//
//  LightSettingsView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/22.
//

import SwiftUI
import CoreData
import MapKit

class LightMapViewModel: NSObject, LightMapViewModelProtocol {
    
    init(light: Light) {
        self.characteristicNumber = light.characteristicNumber
        self.structure = light.structure
        self.name = light.name
        self.volumeNumber = light.volumeNumber
        self.featureNumber = light.featureNumber
        self.noticeWeek = light.noticeWeek
        self.noticeYear = light.noticeYear
        self.latitude = light.latitude
        self.longitude = light.longitude
        self.remarks = light.remarks
        self.characteristic = light.characteristic
        self.range = light.range
        coordinate = light.coordinate
    }
    
    init(characteristicNumber: Int64, structure: String? = nil, name: String? = nil, volumeNumber: String? = nil, featureNumber: String? = nil, noticeWeek: String? = nil, noticeYear: String? = nil, latitude: Double, longitude: Double, remarks: String? = nil, characteristic: String? = nil, range: String? = nil) {
        self.characteristicNumber = characteristicNumber
        self.structure = structure
        self.name = name
        self.volumeNumber = volumeNumber
        self.featureNumber = featureNumber
        self.noticeWeek = noticeWeek
        self.noticeYear = noticeYear
        self.latitude = latitude
        self.longitude = longitude
        self.remarks = remarks
        self.characteristic = characteristic
        self.range = range
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var characteristicNumber: Int64
    
    var structure: String?
    
    var name: String?
        
    var volumeNumber: String?
    
    var featureNumber: String?
        
    var noticeWeek: String?
    
    var noticeYear: String?
        
    @objc var latitude: Double
    
    @objc var longitude: Double
    
    var remarks: String?
    
    var characteristic: String?
    
    var range: String?
    
    
    
    func toRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func toDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    var coordinate: CLLocationCoordinate2D
    
    
}

struct LightSettingsView: View {
    @AppStorage("actualRangeLights") var actualRangeLights = false
    @AppStorage("actualRangeSectorLights") var actualRangeSectorLights = false
    
    @StateObject var mapState: MapState = MapState()

    var lights: [LightMapViewModel] = []
    
    init() {
        let light1: LightMapViewModel = LightMapViewModel(
            characteristicNumber: 1,
            volumeNumber: "PUB 110",
            featureNumber: "14840",
            noticeWeek: "06",
            noticeYear: "2015",
            latitude: 16.473,
            longitude: -61.507,
            remarks: "R. 120°-163°, W.-170°, G.-200°.\n",
            characteristic: "Fl.(2)W.R.G.\nperiod 6s \nfl. 1.0s, ec. 1.0s \nfl. 1.0s, ec. 3.0s \n",
            range: "W. 12 ; R. 9 ; G. 9")
        let light2: LightMapViewModel = LightMapViewModel(
            characteristicNumber: 1,
            volumeNumber: "PUB 110",
            featureNumber: "14836",
            noticeWeek: "24",
            noticeYear: "2019",
            latitude: 16.41861,
            longitude: -61.5338,
            characteristic: "Fl.(3)W.\nperiod 12s \n",
            range: "10")

        lights.append(light1)
        lights.append(light2)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MarlinMap(name: "Light Detail Map", mixins: [LightMap<LightMapViewModel>(objects: lights)], mapState: mapState)
                .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                .onAppear {
                    if lights.count > 0 {
                        mapState.center = MKCoordinateRegion(center: lights[0].coordinate, zoom: 9.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
                    }
                }
                .onChange(of: lights.first) { light in
                    if let firstLight = light {
                        mapState.center = MKCoordinateRegion(center: firstLight.coordinate, zoom: 9.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
                    }
                }
            List {
                Section {
                    Toggle(isOn: $actualRangeSectorLights, label: {
                        HStack {
                            Image(systemName: "rays")
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Sector Light Ranges")
                                    .font(Font.body1)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                                Text("Lights with defined sectors")
                                    .font(Font.caption)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                            }
                            .padding([.top, .bottom], 4)
                        }
                    })
                    .tint(Color.primaryColor)
                    
                    Toggle(isOn: $actualRangeLights, label: {
                        HStack {
                            Image(systemName: "smallcircle.filled.circle.fill")
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Show Light Ranges")
                                    .font(Font.body1)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                                Text("Lights showing an unbroken light over an arc of the horizon of 360 degrees")
                                    .font(Font.caption)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                            }
                            .padding([.top, .bottom], 4)
                        }
                    })
                    .tint(Color.primaryColor)
                } header: {
                    Text("Map Options")
                } footer: {
                    Text("A lights range is the distance, expressed in nautical miles, that a light can be seen in clear weather. These ranges can be visualized on the map. Lights which have defined color sectors, or have visibility or obscured ranges are drawn as arcs of visibility.  All other lights are drawn as full circles.")
                }
            }
            .navigationTitle("Light Settings")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
            .listRowBackground(Color.surfaceColor)
            .background(Color.backgroundColor)
        }
    }
}

struct LightSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        LightSettingsView()
    }
}
