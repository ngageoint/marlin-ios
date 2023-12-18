//
//  LocationFilterFullScreen.swift
//  Marlin
//
//  Created by Daniel Barela on 7/18/23.
//

import SwiftUI
import MapKit

class ObservableCoordinate: ObservableObject {
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    init() {
    }
    
    init(latitude: Double?, longitude: Double?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct LocationFilterFullScreen: View {
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude
    @EnvironmentObject var locationManager: LocationManager
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @State var region: MKCoordinateRegion?
    @Binding var expanded: Bool
    @State var coordinateOne: ObservableCoordinate = ObservableCoordinate()
    @State var coordinateTwo: ObservableCoordinate = ObservableCoordinate()
    @StateObject var mapState: MapState = MapState()
    @StateObject private var mapMixins: MapMixins = MapMixins()
    @State var boundsMixin: LocationBoundsMixin?
    
    var body: some View {
        Self._printChanges()
        
        return Group {
            if viewModel.selectedComparison == .closeTo {
                ZStack(alignment: .bottom) {
                    ZStack {
                        Map(coordinateRegion: $viewModel.region, interactionModes: .all)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(viewModel.dataSourceProperty.name) map input2")
                        Image(systemName: "scope")
                    }
                    .ignoresSafeArea()
                    Text("\(viewModel.dataSourceProperty.name) \(viewModel.readableRegion.center.format())")
                        .secondary()
                        .padding(.all, 4)
                        .background(Color.surfaceColor)
                        .padding(.all, 4)
                }
            } else if viewModel.selectedComparison == .bounds {
                VStack {
                    Text("\(viewModel.dataSourceProperty.name) \(viewModel.readableRegion.center.format())")
                        .secondary()
                        .padding(.all, 4)
                        .background(Color.surfaceColor)
                        .padding(.all, 4)
                        ZStack {
                            MarlinMap(name: "Location Filter", mixins: mapMixins, mapState: mapState, allowMapTapsOnItems: false)
                                .onAppear {
                                    if let boundsMixin = boundsMixin {
                                        mapMixins.mixins.append(boundsMixin)
                                    } else {
                                        boundsMixin = LocationBoundsMixin(region: $viewModel.region, coordinateOne: $coordinateOne, coordinateTwo: $coordinateTwo)
                                        mapMixins.mixins.append(boundsMixin!)
                                    }
                                    mapMixins.mixins.append(UserLayersMap())
                                    region = viewModel.region
                                    mapState.center = viewModel.region
                                }
                            Image(systemName: "scope")
                        }
                        .ignoresSafeArea()
                        
                    if let valueMinLatitude = coordinateOne.latitude, let valueMinLongitude = coordinateOne.longitude {
                        HStack {
                            Text("\(viewModel.dataSourceProperty.name) First Corner **\(CLLocationCoordinate2D(latitude: valueMinLatitude, longitude: valueMinLongitude).format())**")
                                .padding(.all, 8)
                            Spacer()
                            Button {
                                coordinateOne.latitude = nil
                                coordinateOne.longitude = nil
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .tint(Color.red)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("remove corner one")
                            .padding(.all, 8)
                        }
                    } else {
                        Button {
                            coordinateOne.latitude = viewModel.readableRegion.center.latitude
                            coordinateOne.longitude = viewModel.readableRegion.center.longitude
                        } label: {
                            Label(
                                title: {
                                    Text("Set First Corner")
                                },
                                icon: { Image(systemName: "scope")
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .buttonStyle(MaterialButtonStyle(type:.contained))
                        .accessibilityElement()
                        .accessibilityLabel("set first corner")
                    }
                    if let valueMaxLatitude = coordinateTwo.latitude, let valueMaxLongitude = coordinateTwo.longitude {
                        HStack {
                            Text("\(viewModel.dataSourceProperty.name) Second Corner **\(CLLocationCoordinate2D(latitude: valueMaxLatitude, longitude: valueMaxLongitude).format())**")
                                .padding(.all, 8)
                            Spacer()
                            Button {
                                coordinateTwo.latitude = nil
                                coordinateTwo.longitude = nil
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .tint(Color.red)
                            }
                            .accessibilityElement()
                            .accessibilityLabel("remove second corner")
                            .padding(.all, 8)
                        }
                    } else if coordinateOne.latitude != nil {
                        Button {
                            coordinateTwo.latitude = viewModel.readableRegion.center.latitude
                            coordinateTwo.longitude = viewModel.readableRegion.center.longitude
                        } label: {
                            Label(
                                title: {
                                    Text("Set Second Corner")
                                },
                                icon: { Image(systemName: "scope")
                                        .renderingMode(.template)
                                }
                            )
                        }
                        .buttonStyle(MaterialButtonStyle(type: .contained))
                        .accessibilityElement()
                        .accessibilityLabel("set North East corner")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let valueLatitudeOne = coordinateOne.latitude, 
                        let valueLongitudeOne = coordinateOne.longitude,
                        let valueLatitudeTwo = coordinateTwo.latitude,
                        let valueLongitudeTwo = coordinateTwo.longitude {
                        viewModel.valueMinLatitudeString = "\(min(valueLatitudeOne, valueLatitudeTwo))"
                        viewModel.valueMinLongitudeString = "\(min(valueLongitudeOne, valueLongitudeTwo))"
                        viewModel.valueMaxLatitudeString = "\(max(valueLatitudeTwo, valueLatitudeOne))"
                        viewModel.valueMaxLongitudeString = "\(max(valueLongitudeTwo, valueLongitudeTwo))"
                    }

                    expanded.toggle()
                }) {
                    Text("OK")
                        .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                }
                .accessibilityElement()
                .accessibilityLabel("Close Location Filter")
            }
        }
    }
}
