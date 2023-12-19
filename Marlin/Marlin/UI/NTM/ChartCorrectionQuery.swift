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
    
    @State var filterViewModel: PersistedFilterViewModel?
    
    var body: some View {
        VStack {
            if let filterViewModel = filterViewModel {
                FilterView(viewModel: filterViewModel)
                
                if requiredParametersSet {
                    NavigationLink {
                        ChartCorrectionList()
                    } label: {
                        Text("Query")
                    }
                    .buttonStyle(MaterialButtonStyle(type: .text))
                    .accessibilityElement()
                    .accessibilityLabel("Query")
                }
            }
        }
        .padding(.trailing, 8)
        .onAppear {
            if let filterable = DataSourceDefinitions.chartCorrection.filterable {
                filterViewModel = PersistedFilterViewModel(dataSource: filterable, useDefaultForEmptyFilter: true)
            }
            Metrics.shared.appRoute(["ntms", "query"])
            checkRequiredParameters()
        }
        .onChange(of: chartCorrectionFilter) { _ in
            checkRequiredParameters()
        }
    }
    
    func checkRequiredParameters() {
        if UserDefaults.standard.filter(ChartCorrection.definition).contains(where: { $0.property.key == "location" }) {
            requiredParametersSet = true
            return
        }
        requiredParametersSet = false
    }
}
