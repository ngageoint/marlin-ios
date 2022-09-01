//
//  AsamDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI
import MapKit
import CoreData

struct AsamDetailView: View {
    @StateObject var mapState: MapState = MapState()
    var fetchRequest: NSFetchRequest<Asam>

    var asam: Asam
    
    init(asam: Asam) {
        self.asam = asam
        let predicate = NSPredicate(format: "reference == %@", asam.reference ?? "")
        fetchRequest = Asam.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Asam Detail Map", mixins: [AsamMap(fetchRequest: fetchRequest, showAsTiles: false)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: asam.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: asam) { asam in
                            mapState.center = MKCoordinateRegion(center: asam.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    Group {
                        Text(asam.dateString ?? "")
                            .font(Font.overline)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.45)
                        Text("\(asam.hostility ?? "")\(asam.hostility != nil ? ": " : "")\(asam.victim ?? "")")
                            .font(Font.headline6)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        AsamActionBar(asam: asam)
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
            
            Section("Description") {
                Text(asam.asamDescription ?? "")
                    .lineLimit(8)
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
                    .frame(maxWidth:.infinity)
                    .padding(.all, 16)
                    .background(Color.surfaceColor)
                    .modifier(CardModifier())
            }
            .padding(.bottom, -20)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            
            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    if let hostility = asam.hostility {
                        Property(property: "Hostility", value: hostility)
                    }
                    if let victim = asam.victim {
                        Property(property: "Victim", value: victim)
                    }
                    if let reference = asam.reference {
                        Property(property: "Reference Number", value: reference)
                    }
                    if let dateString = asam.dateString {
                        Property(property: "Date of Occurence", value: dateString)
                    }
                    if let subregion = asam.subreg {
                        Property(property: "Geographical Subregion", value: subregion)
                    }
                    if let navarea = asam.navArea {
                        Property(property: "Navigational Area", value: navarea)
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

struct AsamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let asam = try? context.fetchFirst(Asam.self)
        return AsamDetailView(asam: asam!)
    }
}
