//
//  ModuDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI
import MapKit
import CoreData

struct ModuDetailView: View {
    @StateObject var mapState: MapState = MapState()
    var fetchRequest: NSFetchRequest<Modu>
    
    var modu: Modu
    
    init(modu: Modu) {
        self.modu = modu
        let predicate = NSPredicate(format: "name == %@", modu.name ?? "")
        fetchRequest = Modu.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Modu Detail Map", mixins: [ModuMap(fetchRequest: fetchRequest)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: modu.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: modu) { modu in
                            mapState.center = MKCoordinateRegion(center: modu.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    Group {
                        Text(modu.dateString ?? "")
                            .font(Font.overline)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.45)
                        Text("\(modu.name ?? "")")
                            .font(Font.headline6)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        ModuActionBar(modu: modu)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                
                .background(Color.surfaceColor)
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
                .background(Color.surfaceColor)
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
