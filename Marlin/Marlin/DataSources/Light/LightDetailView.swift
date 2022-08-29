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
                    MarlinMap(name: "Light Detail Map", mixins: [LightMap(fetchRequest: fetchRequest, showLightsAsTiles: false)], mapState: mapState)
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    .onAppear {
                        if lights.count > 0 {
                            mapState.center = MKCoordinateRegion(center: lights[0].coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    }
                    .onChange(of: lights.first) { light in
                        if let firstLight = light {
                            mapState.center = MKCoordinateRegion(center: firstLight.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    }
                    Group {
                        Text("\(lights[0].featureNumber ?? "") \(lights[0].internationalFeature ?? "")")
                            .font(Font.overline)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.45)
                        Text("\(lights[0].name ?? "")")
                            .font(Font.headline6)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Text(lights[0].sectionHeader ?? "")
                            .font(Font.body2)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                        Text(lights[0].structure ?? "")
                            .font(Font.body2)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                        if lights[0].heightFeet != 0 {
                            Text("Focal Plane Elevation: \(Int(lights[0].heightFeet))ft (\(Int(lights[0].heightMeters))m)")
                                .font(Font.body2)
                                .foregroundColor(Color.onSurfaceColor)
                                .opacity(0.6)
                        }
                        LightActionBar(light: lights[0], showMoreDetailsButton: false, showFocusButton: true)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                .frame(maxWidth:.infinity)
                .background(Color.surfaceColor)
                .modifier(CardModifier())
                .onAppear {
                    mapState.center = MKCoordinateRegion(center: self.lights[0].coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
                }
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .padding(.top, -24)
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section("Characteristics") {
                ForEach(lights) { light in
                    if light.isLight {
                        LightCard(light: light)
                    } else {
                        RaconCard(racon: light)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 0)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .padding([.trailing, .leading], -8)
        .listStyle(.grouped)
    }
}

struct LightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LightDetailView(featureNumber: "1", volumeNumber: "110")
    }
}
