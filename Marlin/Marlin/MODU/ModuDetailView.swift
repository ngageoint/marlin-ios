//
//  ModuDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI
import MapKit

struct ModuDetailView: View {
        
    @EnvironmentObject var scheme: MarlinScheme
    @State private var region: MKCoordinateRegion
    
    var modu: Modu
    
    init(modu: Modu) {
        self.modu = modu
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: modu.latitude?.doubleValue ?? 0.0, longitude: modu.longitude?.doubleValue ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Map(coordinateRegion: $region, annotationItems: [modu]) { modu in
                        MapAnnotation(coordinate: modu.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)) {
                            Image("modu_marker")
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    Group {
                        Text(modu.dateString ?? "")
                            .font(Font(scheme.containerScheme.typographyScheme.overline))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.45)
                        Text("\(modu.name ?? "")")
                            .font(Font(scheme.containerScheme.typographyScheme.headline6))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.87)
                        HStack(spacing:0) {
                            LatitudeLongitudeButton(latitude: modu.latitude ?? 0.0, longitude: modu.longitude ?? 0.0)
                                .fixedSize()
                                .padding(.leading, -16)
                            Spacer()
                            MaterialButton(image: UIImage(systemName: "square.and.arrow.up")) {
                                print("share button")
                            }.fixedSize()
                            MaterialButton(image: UIImage(systemName: "scope")) {
                                print("share button")
                            }.fixedSize().padding(.trailing, -16)
                        }.padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                
                .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                .modifier(CardModifier())
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .padding(.top, -24)
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    if let rigStatus = modu.rigStatus {
                        Property(property: "Rig Status", value: rigStatus)
                    }
                    if let specialStatus = modu.specialStatus {
                        Property(property: "Special Status", value: specialStatus)
                    }
                    if let distance = modu.distance, distance != 0 {
                        Property(property: "Distance", value: "\(distance)")
                    }
                    if let navArea = modu.navArea {
                        Property(property: "Navigational Area", value: navArea)
                    }
                    if let subregion = modu.subregion {
                        Property(property: "Charting Subregion", value: "\(subregion)")
                    }
                    
                }
                .padding(.all, 16)
                .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                .modifier(CardModifier())
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        
        .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        .listStyle(.grouped)
        
    }
}

struct ModuDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let modu = try? context.fetchFirst(Modu.self)
        return ModuDetailView(modu: modu!)
    }
}
