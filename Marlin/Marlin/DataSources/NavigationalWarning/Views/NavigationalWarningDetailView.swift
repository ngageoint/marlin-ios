//
//  NavigationalWarningDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningDetailView: View {
    @ObservedObject var navigationalWarning: NavigationalWarning
    
    @State var mappedLocation: MappedLocation?
    @State var fetchPredicate: NSPredicate?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(navigationalWarning.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: NavigationalWarning.color))
                        .padding(.bottom, -8)
                    if let fetchPredicate = fetchPredicate, CLLocationCoordinate2DIsValid(navigationalWarning.coordinate) {
                        DataSourceLocationMapView(dataSourceLocation: navigationalWarning, mapName: "Navigational Warning Detail Map", mixins: [NavigationalWarningFetchMap(fetchPredicate: fetchPredicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    Group {
                        Text(navigationalWarning.dateString ?? "")
                            .overline()
                            .padding(.top, 16)
                        Property(property: "Authority", value: navigationalWarning.authority)
                        Property(property: "Cancel Date", value: navigationalWarning.cancelDateString)
                        if let cancelNavArea = navigationalWarning.cancelNavArea, let navAreaEnum = NavigationalWarningNavArea.fromId(id: cancelNavArea){
                            Property(property: "Cancelled By", value: "\(navAreaEnum.display) \(navigationalWarning.cancelMsgNumber)/\(navigationalWarning.cancelMsgYear)")
                        }
                        NavigationalWarningActionBar(navigationalWarning: navigationalWarning, showMoreDetails: false, mapName: "Navigational Warning Detail Map")
                            .padding(.bottom, 16)
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
                        .padding(.all, 16)
                        .card()
                }
                .dataSourceSection()
            }
        }
        .dataSourceDetailList()
        .navigationTitle("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: navigationalWarning, perform: { newValue in
            self.mappedLocation = navigationalWarning.mappedLocation
            self.fetchPredicate = NSPredicate(format: "self == %@", navigationalWarning.objectID)
        })
        .onAppear {
            self.mappedLocation = navigationalWarning.mappedLocation
            self.fetchPredicate = NSPredicate(format: "self == %@", navigationalWarning.objectID)
            Metrics.shared.dataSourceDetail(dataSource: NavigationalWarning.self)
        }
    }
}
