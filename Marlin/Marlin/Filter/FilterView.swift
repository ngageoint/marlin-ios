//
//  FilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI
import CoreLocation

struct FilterView: View {
    @ObservedObject var locationManager: LocationManager = LocationManager.shared
    
    @ObservedObject var viewModel: FilterViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.filters.isEmpty {
                Text("Current Filter")
                    .secondary()
            }
            ForEach(Array(viewModel.filters.enumerated()), id: \.element) { index, filter in
                HStack {
                    FilterParameterSummaryView(filter: filter, dataSource: viewModel.dataSource)
                    Spacer()
                    Button {
                        viewModel.filters.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                }
                .padding([.top, .bottom], 8)
                Divider()
            }
            let requiredProperties = viewModel.dataSource.properties.filter({ property in
                property.requiredInFilter
            })
            let requiredNotSet = requiredProperties.filter { property in
                !viewModel.filters.contains { parameter in
                    parameter.property.key == property.key
                }
            }
            
            if !requiredProperties.isEmpty {
                if !requiredNotSet.isEmpty {

                    ForEach(requiredNotSet) { property in
                        Text("Add Required Filter Parameters")
                            .secondary()
                        
                        DataSourcePropertyFilterView(filterViewModel: viewModel)
                            .onAppear {
                                viewModel.staticProperty = property
                            }
                    }
                    Divider()
                } else {
                    Text("Add Additional Filter Parameters")
                        .secondary()
                }
            }
            if requiredNotSet.isEmpty {
                DataSourcePropertyFilterView(filterViewModel: viewModel)
                    .onAppear {
                        viewModel.staticProperty = nil
                    }
                .padding(.top, 8)
                .padding(.leading, -8)
            }
        }
        .padding([.leading, .bottom], 16)
        .padding(.trailing, 0)
        .onAppear {
            UserDefaults.standard.setFilter(viewModel.dataSource.key, filter: viewModel.filters)
        }
    }
}

