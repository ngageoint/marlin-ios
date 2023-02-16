//
//  LocationFilter.swift
//  Marlin
//
//  Created by Daniel Barela on 12/2/22.
//

import SwiftUI
import MapKit

struct LocationFilter<Location>: View where Location: LocationManagerProtocol {
    @ObservedObject var locationManager: Location

    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var viewModel: DataSourcePropertyFilterViewModel
    @FocusState var isInputActive: Bool
    @State var mapTapped: Bool = false
    
    init(locationManager: Location = LocationManager.shared, filterViewModel: FilterViewModel, viewModel: DataSourcePropertyFilterViewModel) {
        self.locationManager = locationManager
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

                            Text("Tap To Set Location")
                                .secondary()
                                .padding(.all, 4)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
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
                if locationManager.lastLocation == nil {
                    Text("No current location")
                        .secondary()
                        .padding([.leading, .top], 12)
                } else {
                    Map(coordinateRegion: $viewModel.currentRegion, showsUserLocation: true)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .tint(Color.primaryColorVariant)
                        .padding(.bottom, 8)
                    distanceFilter()
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
