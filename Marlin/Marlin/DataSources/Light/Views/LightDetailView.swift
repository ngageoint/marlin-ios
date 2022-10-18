//
//  LightDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/7/22.
//

import SwiftUI
import MapKit
import CoreData

struct LightDetailView: View {
    
    @FetchRequest var lights : FetchedResults<Light>
    var fetchRequest: NSFetchRequest<Light>
    var featureNumber: String
    var volumeNumber: String
    
    @StateObject var mapState: MapState = MapState()
    
    init(featureNumber: String, volumeNumber: String) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
        
        let predicate = NSPredicate(format: "featureNumber == %@ AND volumeNumber == %@", self.featureNumber, self.volumeNumber)

        //Intialize the FetchRequest property wrapper
        self._lights = FetchRequest(entity: Light.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Light.characteristicNumber, ascending: true)], predicate: predicate)
        fetchRequest = Light.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Light Detail Map", mixins: [LightMap<Light>(fetchPredicate: fetchRequest.predicate)], mapState: mapState)
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    .onAppear {
                        if lights.count > 0 {
                            mapState.center = MKCoordinateRegion(center: lights[0].coordinate, zoom: 14.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
                        }
                    }
                    .onChange(of: lights.first) { light in
                        if let firstLight = light {
                            mapState.center = MKCoordinateRegion(center: firstLight.coordinate, zoom: 14.5, bounds: CGRect(x: 0, y: 0, width: 600, height: 600))
                        }
                    }
                    Group {
                        Text("\(lights[0].featureNumber ?? "") \(lights[0].internationalFeature ?? "")")
                            .overline()
                        Text("\(lights[0].name ?? "")")
                            .primary()
                        Text(lights[0].sectionHeader ?? "")
                            .secondary()
                        Text(lights[0].structure ?? "")
                            .secondary()
                        if lights[0].heightFeet != 0 {
                            Text("Focal Plane Elevation: \(Int(lights[0].heightFeet))ft (\(Int(lights[0].heightMeters))m)")
                                .secondary()
                        }
                        LightActionBar(light: lights[0], showMoreDetailsButton: false, showFocusButton: true)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                .frame(maxWidth:.infinity)
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            Section("Characteristics") {
                ForEach(lights) { light in
                    if light.isLight {
                        LightCard(light: light)
                            .padding(.bottom, 16)
                    } else {
                        RaconCard(racon: light)
                            .padding(.bottom, 16)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .dataSourceSection()
        }
        .dataSourceDetailList()
    }
}

struct LightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LightDetailView(featureNumber: "1", volumeNumber: "110")
    }
}
