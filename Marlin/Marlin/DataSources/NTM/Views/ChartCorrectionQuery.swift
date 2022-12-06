//
//  ChartCorrectionQuery.swift
//  Marlin
//
//  Created by Daniel Barela on 11/16/22.
//

import SwiftUI

struct ChartCorrectionQuery: View {
    @AppStorage("\(ChartCorrection.key)Filter") var chartCorrectionFilter: Data?
    @State private var requiredParametersSet: Bool = false
    
    var filterViewModel: FilterViewModel = FilterViewModel(dataSource: ChartCorrection.self, useDefaultForEmptyFilter: true)
    
    var body: some View {
        VStack {
            FilterView(viewModel: filterViewModel)
            
            if requiredParametersSet {
                NavigationLink {
                    ChartCorrectionList()
                } label: {
                    Text("Query")
                    
                }
                .buttonStyle(MaterialButtonStyle(type: .text))
            }
        }
        .padding(.trailing, 8)
        .onAppear {
            checkRequiredParameters()
        }
        .onChange(of: chartCorrectionFilter) { newValue in
            checkRequiredParameters()
        }
    }
    
    func checkRequiredParameters() {
        for filter in UserDefaults.standard.filter(ChartCorrection.self) {
            if filter.property.key == "location" {
                requiredParametersSet = true
                return
            }
        }
        requiredParametersSet = false
    }
}
