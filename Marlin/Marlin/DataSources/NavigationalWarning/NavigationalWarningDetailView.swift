//
//  NavigationalWarningDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI

struct NavigationalWarningDetailView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var navigationalWarning: NavigationalWarning
    
    init(navigationalWarning: NavigationalWarning) {
        self.navigationalWarning = navigationalWarning
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(navigationalWarning.dateString ?? "")
                        .overline()
                    Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                        .primary()
                    if let status = navigationalWarning.status {
                        Property(property: "Status", value: status)
                    }
                    if let authority = navigationalWarning.authority {
                        Property(property: "Authority", value: authority)
                    }
                    if let cancelDateString = navigationalWarning.cancelDateString {
                        Property(property: "Cancel Date", value: cancelDateString)
                    }
                    if let cancelNavArea = navigationalWarning.cancelNavArea, let cancelMsgNumber = navigationalWarning.cancelMsgNumber, let cancelMsgYear = navigationalWarning.cancelMsgYear, let navAreaEnum = NavigationalWarningNavArea.fromId(id: cancelNavArea){
                        Property(property: "Cancelled By", value: "\(navAreaEnum.display) \(cancelMsgNumber)/\(cancelMsgYear)")
                    }
                    NavigationalWarningActionBar(navigationalWarning: navigationalWarning)
                }
                .padding(.all, 16)
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            Section("Text") {
                Text(navigationalWarning.text ?? "")
                    .multilineTextAlignment(.leading)
                    .secondary()
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.all, 16)
                    .card()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NavigationalWarningDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let navigationalWarning = try? context.fetchFirst(NavigationalWarning.self)
        NavigationalWarningDetailView(navigationalWarning: navigationalWarning!)
    }
}
