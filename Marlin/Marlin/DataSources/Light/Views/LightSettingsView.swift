//
//  LightSettingsView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/22.
//

import SwiftUI
import CoreData
import MapKit

struct LightSettingsView: View {
    @AppStorage("actualRangeLights") var actualRangeLights = false
    @AppStorage("actualRangeSectorLights") var actualRangeSectorLights = false
    
    @FetchRequest var lights : FetchedResults<Light>
    var fetchRequest: NSFetchRequest<Light>
    
    @StateObject var mapState: MapState = MapState()
    
    init() {
        let sectorLightFeatureNumber = "14840"
        let sectorLightVolumeNumber = "PUB 110"
        let fullLightFeatureNumber = "14836"
        let fullLightVolumeNumber = "PUB 110"
        
        let predicate = NSPredicate(format: "(featureNumber == %@ AND volumeNumber == %@) OR (featureNumber == %@ AND volumeNumber == %@)", sectorLightFeatureNumber, sectorLightVolumeNumber, fullLightFeatureNumber, fullLightVolumeNumber)
        
        //Intialize the FetchRequest property wrapper
        self._lights = FetchRequest(entity: Light.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Light.characteristicNumber, ascending: true)], predicate: predicate)
        fetchRequest = Light.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MarlinMap(name: "Light Detail Map", mixins: [LightMap(fetchRequest: fetchRequest)], mapState: mapState)
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
