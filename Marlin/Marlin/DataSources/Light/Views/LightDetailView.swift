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
        
    init(featureNumber: String, volumeNumber: String) {
        self.featureNumber = featureNumber
        self.volumeNumber = volumeNumber
        
        let predicate = NSPredicate(format: "featureNumber == %@ AND volumeNumber == %@", self.featureNumber, self.volumeNumber)

        self._lights = FetchRequest(entity: Light.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Light.characteristicNumber, ascending: true)], predicate: predicate)
        fetchRequest = Light.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        if lights.count > 0 {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        if let firstLight = lights.first {
                            DataSourceLocationMapView(dataSourceLocation: firstLight, mapName: "Light Detail Map", mixins: [LightMap<Light>(fetchPredicate: fetchRequest.predicate)])
                                .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        }
                        Group {
                            Text("\(lights[0].featureNumber ?? "") \(lights[0].internationalFeature ?? "") \(lights[0].volumeNumber ?? "")")
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
            .onAppear {
                Metrics.shared.dataSourceDetail(dataSource: Light.self)
            }
        } else {
            Text("Loading Light \(self.featureNumber) \(self.volumeNumber)")
        }
    }
}
