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
    
    @State var filters: [DataSourceFilterParameter] {
        didSet {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
    }
    
    var dataSourceProperties: [DataSourceProperty]
    var dataSource: any DataSource.Type
    
    @State private var selectedProperty: DataSourceProperty
    
    @State private var filterParameter: DataSourceFilterParameter?
    
    init(dataSource: any DataSource.Type, useDefaultForEmptyFilter: Bool = false) {
        self.dataSource = dataSource
        self.dataSourceProperties = dataSource.properties
        let savedFilter = UserDefaults.standard.filter(dataSource)
        if useDefaultForEmptyFilter && savedFilter.isEmpty {
            self._filters = State(initialValue: dataSource.defaultFilter)
        } else {
            self._filters = State(initialValue: savedFilter)
        }
        self._selectedProperty = State(initialValue: dataSourceProperties[0])
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !filters.isEmpty {
                Text("Current Filter")
                    .secondary()
            }
            ForEach(Array(filters.enumerated()), id: \.element) { index, filter in
                HStack {
                    FilterParameterSummaryView(filter: filter, dataSource: dataSource)
                    Spacer()
                    Button {
                        filters.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                }
                .padding([.top, .bottom], 8)
                Divider()
            }
            let requiredProperties = dataSourceProperties.filter({ property in
                property.requiredInFilter
            })
            let requiredNotSet = requiredProperties.filter { property in
                !filters.contains { parameter in
                    parameter.property.key == property.key
                }
            }
            
            if !requiredProperties.isEmpty {
                if !requiredNotSet.isEmpty {

                    ForEach(requiredNotSet) { property in
                        Text("Add Required Filter Parameters")
                            .secondary()
                        DataSourcePropertyFilterView(dataSourceProperty: property, filterParameter: $filterParameter)
                    }
                    Divider()
                } else {
                    Text("Add Additional Filter Parameters")
                        .secondary()
                }
            }
            if requiredNotSet.isEmpty {
                DataSourcePropertyFilterView(dataSourceProperties: dataSourceProperties, filterParameter: $filterParameter)
                .padding(.top, 8)
                .padding(.leading, -8)
            }
        }
        .padding([.leading, .bottom], 16)
        .padding(.trailing, 0)
        .onAppear {
            UserDefaults.standard.setFilter(dataSource.key, filter: filters)
        }
        .onChange(of: filterParameter, perform: { newValue in
            if let newValue = newValue {
                print("filter parameter changed \(newValue)")
                filters.append(newValue)
            }
        })
    }
}

