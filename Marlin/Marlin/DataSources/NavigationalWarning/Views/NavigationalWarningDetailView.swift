//
//  NavigationalWarningDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningDetailView: View {
    var navigationalWarning: NavigationalWarning
    
    var mappedLocation: MappedLocation?
    
    init(navigationalWarning: NavigationalWarning) {
        self.navigationalWarning = navigationalWarning
        self.mappedLocation = navigationalWarning.mappedLocation
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if CLLocationCoordinate2DIsValid(navigationalWarning.coordinate) {
                        DataSourceLocationMapView(dataSourceLocation: navigationalWarning, mapName: "Navigational Warning Detail Map", mixins: [NavigationalWarningMap(warning: navigationalWarning)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    Group {
                        Text(navigationalWarning.dateString ?? "")
                            .overline()
                            .padding(.top, 16)
                        Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                            .primary()
                        Property(property: "Status", value: navigationalWarning.status)
                        Property(property: "Authority", value: navigationalWarning.authority)
                        Property(property: "Cancel Date", value: navigationalWarning.cancelDateString)
                        if let cancelNavArea = navigationalWarning.cancelNavArea, let navAreaEnum = NavigationalWarningNavArea.fromId(id: cancelNavArea){
                            Property(property: "Cancelled By", value: "\(navAreaEnum.display) \(navigationalWarning.cancelMsgNumber)/\(navigationalWarning.cancelMsgYear)")
                        }
                        NavigationalWarningActionBar(navigationalWarning: navigationalWarning, showMoreDetails: false)
                    }.padding([.leading, .trailing], 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            if let text = navigationalWarning.text {
                Section("Warning") {
                    UITextViewContainer(text:text)
                        .multilineTextAlignment(.leading)
                        .textSelection(.enabled)
                        .tint(Color.purple)
                        .padding(.all, 16)
                        .card()
                }
                .dataSourceSection()
            }
        }
        .dataSourceDetailList()
        .navigationTitle("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: NavigationalWarning.self)
        }
    }
}
