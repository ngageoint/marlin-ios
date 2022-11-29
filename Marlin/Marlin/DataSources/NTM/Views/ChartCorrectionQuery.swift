//
//  ChartCorrectionQuery.swift
//  Marlin
//
//  Created by Daniel Barela on 11/16/22.
//

import SwiftUI

struct ChartCorrectionQuery: View {
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    @State var filterCount: Int = ChartCorrection.defaultFilter.count
    
    @State private var selectedComparison: DataSourceFilterComparison = .equals
    @State private var selectedEnumeration: String = ""
    @State private var valueString: String = ""
    @State private var valueDate: Date = Date()
    @State private var valueInt: Int?// = 0
    @State private var valueDouble: Double?// = 0.0
    @State private var valueLatitude: Double?// = 0.0
    @State private var valueLongitude: Double?// = 0.0
    @State private var windowUnits: DataSourceWindowUnits? // = .last30Days
    
    @State private var requiredParametersSet: Bool = false
    
    let properties: [DataSourceProperty] = [DataSourceProperty(name: "Location", key: "location", type: .location), DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int)]
    
    var body: some View {
        VStack {
            FilterView(dataSource: ChartCorrection.self, useDefaultForEmptyFilter: true)
            
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
        .onReceive(dataSourceUpdatedPub) { output in
            checkRequiredParameters()
        }
        .onAppear {
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
    
//    @ViewBuilder
//    func propertyNameAndComparison(property: DataSourceProperty) -> some View {
//        HStack {
//            Text(property.name).primary()
//            
//            FilterComparison(property: property, selectedComparison: $selectedComparison)
//        }
//    }
}
