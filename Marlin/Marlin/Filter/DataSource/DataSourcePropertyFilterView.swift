//
//  DataSourcePropertyFilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 12/1/22.
//

import SwiftUI
import Combine

struct DataSourcePropertyFilterView: View {
    @EnvironmentObject var locationManager: LocationManager

    var filterViewModel: FilterViewModel
    
    @StateObject var viewModel: DataSourcePropertyFilterViewModel
    
    init(dataSourceProperty: DataSourceProperty? = nil, filterViewModel: FilterViewModel) {
        var prop = dataSourceProperty ?? DataSourceProperty(name: "", key: "", type: .string)
        if let filterable = filterViewModel.dataSource, dataSourceProperty == nil && !filterable.properties.isEmpty {
            prop = filterable.properties[0]
        }
        self.filterViewModel = filterViewModel

        _viewModel = StateObject(
            wrappedValue: DataSourcePropertyFilterViewModel(
                dataSourceProperty: prop,
                isStaticProperty: dataSourceProperty != nil
            )
        )
    }
    
    var body: some View {
        HStack(alignment: viewModel.dataSourceProperty.type == .location ? .bottom : .center) {
            switch viewModel.dataSourceProperty.type {
            case .double, .float:
                DoubleFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .int:
                IntFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .date:
                DateFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .enumeration:
                EnumerationFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .location:
                LocationFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .latitude, .longitude:
                LatitudeLongitudeFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .string:
                StringFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            case .boolean:
                BooleanFilter(filterViewModel: filterViewModel, viewModel: viewModel)
            }
            Spacer()
            Button {
                filterViewModel.addFilterParameter(viewModel: viewModel)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .tint(Color.green)
            }
            .disabled(!viewModel.isValid)
            .padding(.bottom, viewModel.dataSourceProperty.type == .location ? 12 : 0)
        }
        .onAppear {
            viewModel.locationManager = locationManager
        }
    }
}
