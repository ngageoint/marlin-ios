//
//  AsamDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI
import MapKit

struct AsamDetailView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    @State private var region: MKCoordinateRegion

    var asam: Asam
    
    init(asam: Asam) {
        self.asam = asam
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: asam.latitude?.doubleValue ?? 0.0, longitude: asam.longitude?.doubleValue ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {

                    Map(coordinateRegion: $region, annotationItems: [asam]) { asam in
                        MapAnnotation(coordinate: asam.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)) {
                            Image("asam_marker")
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    Group {
                        Text(asam.dateString ?? "")
                            .font(Font(scheme.containerScheme.typographyScheme.overline))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.45)
                        Text("\(asam.hostility ?? "")\(asam.hostility != nil ? ": " : "")\(asam.victim ?? "")")
                            .font(Font(scheme.containerScheme.typographyScheme.headline6))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.87)
                        HStack(spacing:0) {
                            LatitudeLongitudeButton(latitude: asam.latitude ?? 0.0, longitude: asam.longitude ?? 0.0)
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
            
            Section("Description") {
                Text(asam.asamDescription ?? "")
                    .lineLimit(8)
                    .font(Font(scheme.containerScheme.typographyScheme.body2))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                    .opacity(0.6)
                    .frame(maxWidth:.infinity)
                    .padding(.all, 16)
                    .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
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

struct AsamDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let asam = try? context.fetchFirst(Asam.self)
        return AsamDetailView(asam: asam!)
    }
}
