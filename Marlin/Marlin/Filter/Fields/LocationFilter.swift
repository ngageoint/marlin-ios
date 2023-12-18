//
//  LocationFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI
import MapKit

struct LocationFilter: View {
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude

    @EnvironmentObject var locationManager: LocationManager

    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @FocusState var isInputActive: Bool
    @State var mapTapped: Bool = false
    @StateObject var mapState: MapState = MapState()
    @StateObject private var mapMixins: MapMixins = MapMixins()
    @State var boundsMixin: LocationBoundsMixin?
    @State var coordinateOne: ObservableCoordinate = ObservableCoordinate()
    @State var coordinateTwo: ObservableCoordinate = ObservableCoordinate()
    
    init(filterViewModel: FilterViewModel, viewModel: DataSourcePropertyFilterViewModel) {
        self.filterViewModel = filterViewModel
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                FilterPropertyName(filterViewModel: filterViewModel, viewModel: viewModel)
                FilterComparison(dataSourcePropertyFilterViewModel: viewModel)
            }
            if viewModel.selectedComparison == .closeTo {
                ZStack {
                    if !isInputActive && mapTapped {
                        Map(coordinateRegion: $viewModel.region, interactionModes: .all)
                            .frame(maxWidth: .infinity)
                            .frame(height: 250)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(viewModel.dataSourceProperty.name) map input2")
                    } else {
                        ZStack(alignment: .topLeading) {
                            VStack {
                                Map(coordinateRegion: $viewModel.readableRegion)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 250)
                                    .disabled(true)
                            }

                            Text("Tap To Set Location Via Map")
                                .secondary()
                                .padding(.all, 4)
                                .background(Color.surfaceColor)
                                .padding(.all, 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            mapTapped = true
                            isInputActive = false
                        }
                        .onLongPressGesture {
                            mapTapped = true
                            isInputActive = false
                        }
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("\(viewModel.dataSourceProperty.name) map input")
                    }
                    Image(systemName: "scope")
                }
                .padding(.bottom, 8)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Latitude")
                            .overline()
                            .padding(.leading, 8)
                            .padding(.bottom, -16)
                        TextField("Latitude", text: $viewModel.valueLatitudeString)
                            .underlineTextField()
                            .textInputAutocapitalization(.never)
                            .onTapGesture(perform: {
                                mapTapped = false
                                viewModel.startValidating = true
                            })
                            .focused($isInputActive)
                            .accessibilityElement()
                            .accessibilityLabel("\(viewModel.dataSourceProperty.name) latitude input")
                        if let validationLatitudeText = viewModel.validationLatitudeText {
                            Text(validationLatitudeText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Longitude")
                            .overline()
                            .padding(.leading, 8)
                            .padding(.bottom, -16)
                        TextField("Longitude", text: $viewModel.valueLongitudeString)
                            .underlineTextField()
                            .textInputAutocapitalization(.never)
                            .onTapGesture(perform: {
                                mapTapped = false
                                viewModel.startValidating = true
                            })
                            .focused($isInputActive)
                            .accessibilityElement()
                            .accessibilityLabel("\(viewModel.dataSourceProperty.name) longitude input")
                        if let validationLongitudeText = viewModel.validationLongitudeText {
                            Text(validationLongitudeText)
                                .overline()
                                .padding(.leading, 8)
                        }
                    }
                }
                .padding(.leading, 4)
                distanceFilter()
            } else if viewModel.selectedComparison == .nearMe {
                if let lastLocation = locationManager.lastLocation {
                    Text(coordinateDisplay.format(coordinate: lastLocation.coordinate))
                        .overline()
                        .padding(.leading, 8)
                    Map(coordinateRegion: $viewModel.currentRegion, showsUserLocation: true)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .tint(Color.primaryColorVariant)
                        .padding(.bottom, 8)
                    distanceFilter()
                } else {
                    Text("No current location")
                        .secondary()
                        .padding([.leading, .top], 12)
                }
            } else if viewModel.selectedComparison == .bounds {
                VStack {
                    ZStack(alignment: .topLeading) {
                        VStack {
                            MarlinMap(
                                name: "Location Filter",
                                mixins: mapMixins,
                                mapState: mapState,
                                allowMapTapsOnItems: false)
                                .onAppear {
                                    if let boundsMixin = boundsMixin {
                                        mapMixins.mixins.append(boundsMixin)
                                    } else {
                                        boundsMixin = LocationBoundsMixin(
                                            region: $viewModel.region,
                                            coordinateOne: $coordinateOne,
                                            coordinateTwo: $coordinateTwo)
                                        mapMixins.mixins.append(boundsMixin!)
                                    }
                                    mapMixins.mixins.append(UserLayersMap())
                                    mapState.center = viewModel.region
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .onChange(of: [
                                    viewModel.valueMinLatitudeString,
                                    viewModel.valueMinLongitudeString,
                                    viewModel.valueMaxLatitudeString,
                                    viewModel.valueMaxLongitudeString]) { newValue in
                                    if let minLat = viewModel.valueMinLatitude, 
                                        let minLon = viewModel.valueMinLongitude,
                                        let maxLat = viewModel.valueMaxLatitude,
                                        let maxLon = viewModel.valueMaxLongitude {
                                        coordinateOne.latitude = minLat
                                        coordinateOne.longitude = minLon
                                        coordinateTwo.latitude = maxLat
                                        coordinateTwo.longitude = maxLon
                                        let center = CLLocationCoordinate2D(
                                            latitude: maxLat - ((maxLat - minLat) / 2.0),
                                            longitude: maxLon - ((maxLon - minLon) / 2.0))
                                        mapState.center = MKCoordinateRegion(
                                            center: center,
                                            span: MKCoordinateSpan(
                                                latitudeDelta: maxLat - minLat,
                                                longitudeDelta: maxLon - minLon))
                                    }
                                }
                        }
                        
                        Text("Tap To Set Location Via Map")
                            .secondary()
                            .padding(.all, 4)
                            .background(Color.surfaceColor)
                            .padding(.all, 4)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        mapTapped = true
                        isInputActive = false
                    }
                    .onLongPressGesture {
                        mapTapped = true
                        isInputActive = false
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(viewModel.dataSourceProperty.name) map input")
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Min Latitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("Min Latitude", text: $viewModel.valueMinLatitudeString)
                                .underlineTextField()
                                .textInputAutocapitalization(.never)
                                .onTapGesture(perform: {
                                    mapTapped = false
                                    viewModel.startValidating = true
                                })
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("\(viewModel.dataSourceProperty.name) min latitude input")
                            if let validationLatitudeText = viewModel.validationMinLatitudeText {
                                Text(validationLatitudeText)
                                    .overline()
                                    .padding(.leading, 8)
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Min Longitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("Min Longitude", text: $viewModel.valueMinLongitudeString)
                                .underlineTextField()
                                .textInputAutocapitalization(.never)
                                .onTapGesture(perform: {
                                    mapTapped = false
                                    viewModel.startValidating = true
                                })
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("\(viewModel.dataSourceProperty.name) min longitude input")
                            if let validationLongitudeText = viewModel.validationMinLongitudeText {
                                Text(validationLongitudeText)
                                    .overline()
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(.leading, 4)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Max Latitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("Max Latitude", text: $viewModel.valueMaxLatitudeString)
                                .underlineTextField()
                                .textInputAutocapitalization(.never)
                                .onTapGesture(perform: {
                                    mapTapped = false
                                    viewModel.startValidating = true
                                })
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("\(viewModel.dataSourceProperty.name) max latitude input")
                            if let validationLatitudeText = viewModel.validationMaxLatitudeText {
                                Text(validationLatitudeText)
                                    .overline()
                                    .padding(.leading, 8)
                            }
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Max Longitude")
                                .overline()
                                .padding(.leading, 8)
                                .padding(.bottom, -16)
                            TextField("Max Longitude", text: $viewModel.valueMaxLongitudeString)
                                .underlineTextField()
                                .textInputAutocapitalization(.never)
                                .onTapGesture(perform: {
                                    mapTapped = false
                                    viewModel.startValidating = true
                                })
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("\(viewModel.dataSourceProperty.name) max longitude input")
                            if let validationLongitudeText = viewModel.validationMaxLongitudeText {
                                Text(validationLongitudeText)
                                    .overline()
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isInputActive = false
                }
                .tint(Color.primaryColorVariant)
            }
        }
        .sheet(isPresented: $mapTapped) {
            NavigationStack {
                LocationFilterFullScreen(viewModel: viewModel, expanded: $mapTapped)

                .navigationTitle("Set \(viewModel.dataSourceProperty.name)")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.backgroundColor)
            }
            .environmentObject(LocationManager.shared())
            .presentationDetents([.large])
        }
    }
    
    @ViewBuilder
    func distanceFilter() -> some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Distance")
                    .overline()
                    .padding(.leading, 8)
                    .padding(.bottom, -16)
                TextField("Nautical Miles", value: $viewModel.valueInt, format: .number.grouping(.never))
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .underlineTextField()
                    .onTapGesture(perform: {
                        mapTapped = false
                        viewModel.startValidating = true
                    })
                    .focused($isInputActive)
                    .accessibilityElement()
                    .accessibilityLabel("\(viewModel.dataSourceProperty.name) distance input")
                if let validationText = viewModel.validationText {
                    Text(validationText)
                        .overline()
                        .padding(.leading, 8)
                }
            }
            Text("nm")
                .overline()
                .padding(.bottom, 16)
        }
        .padding(.leading, 4)
    }
}
