//
//  LightDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/7/22.
//

import SwiftUI
import MapKit

struct LightDetailView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    @State private var region: MKCoordinateRegion
    
    @FetchRequest var lights : FetchedResults<Lights>
    var featureNumber: String
    var volumeNumber: String
    
    init(featureNumber: String, volumeNumber: String) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
        _region = State(initialValue: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)))
        
        let predicate = NSPredicate(format: "featureNumber == %@ AND volumeNumber == %@", self.featureNumber, self.volumeNumber)

        //Intialize the FetchRequest property wrapper
        self._lights = FetchRequest(entity: Lights.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Lights.characteristicNumber, ascending: true)], predicate: predicate)
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap()
                        .mixin(LightMap(lights: lights.map { $0 }))
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    Group {
                        Text("\(lights[0].featureNumber ?? "") \(lights[0].internationalFeature ?? "")")
                            .font(Font(scheme.containerScheme.typographyScheme.overline))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.45)
                        Text("\(lights[0].name ?? "")")
                            .font(Font(scheme.containerScheme.typographyScheme.headline6))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.87)
                        Text(lights[0].sectionHeader ?? "")
                            .font(Font(scheme.containerScheme.typographyScheme.body2))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.6)
                        Text(lights[0].structure ?? "")
                            .font(Font(scheme.containerScheme.typographyScheme.body2))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.6)
                        if lights[0].heightFeet != 0 {
                            Text("Focal Plane Elevation: \(Int(lights[0].heightFeet))ft (\(Int(lights[0].heightMeters))m)")
                                .font(Font(scheme.containerScheme.typographyScheme.body2))
                                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                                .opacity(0.6)
                        }
                        LightActionBar(light: lights[0], showMoreDetailsButton: false, showFocusButton: true)
                    }.padding([.leading, .trailing], 16)
                }
                .frame(maxWidth:.infinity)
                .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                .modifier(CardModifier())
                .onAppear {
                    self.region = MKCoordinateRegion(center: self.lights[0].coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
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
