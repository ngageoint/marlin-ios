//
//  FilterView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI
import CoreLocation

struct FilterView: View {    
    @ObservedObject var viewModel: FilterViewModel
        
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !viewModel.filters.isEmpty {
                Text("Current Filter")
                    .secondary()
            } else {
                Text("No Current Filter")
                    .secondary()
            }
            ForEach(Array(viewModel.filters.enumerated()), id: \.element) { index, filter in
                HStack {
                    Text(.init(filter.display()))
                    Spacer()
                    Button {
                        viewModel.filters.remove(at: index)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                    .accessibilityElement()
                    .accessibilityLabel("remove filter \(index)")
                }
                .padding([.top, .bottom], 8)
                Divider()
            }
            if !viewModel.requiredProperties.isEmpty {
                if !viewModel.requiredNotSet.isEmpty {
                    Text("Add Required Filter Parameters")
                        .secondary()
                    
                    ForEach(viewModel.requiredNotSet) { property in
                        DataSourcePropertyFilterView(dataSourceProperty: property, filterViewModel: viewModel)
                    }
                    Divider()
                } else {
                    Text("Add Additional Filter Parameters")
                        .secondary()
                }
            }
            if viewModel.requiredNotSet.isEmpty {
                DataSourcePropertyFilterView(filterViewModel: viewModel)
                .padding(.top, 8)
                .padding(.leading, -8)
            }
        }
        .padding([.leading, .bottom], 16)
        .padding(.trailing, 0)
    }
}

