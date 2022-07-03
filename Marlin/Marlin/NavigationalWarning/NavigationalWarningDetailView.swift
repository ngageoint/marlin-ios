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
                        .font(Font(scheme.containerScheme.typographyScheme.overline))
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                        .opacity(0.45)
                    Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                        .font(Font(scheme.containerScheme.typographyScheme.headline6))
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                        .opacity(0.87)
                    if let status = navigationalWarning.status {
                        Property(property: "Status", value: status)
                    }
                    if let authority = navigationalWarning.authority {
                        Property(property: "Authority", value: authority)
                    }
                    if let cancelDateString = navigationalWarning.cancelDateString {
                        Property(property: "Cancel Date", value: cancelDateString)
                    }
                    if let cancelNavArea = navigationalWarning.cancelNavArea, let cancelMsgNumber = navigationalWarning.cancelMsgNumber, let cancelMsgYear = navigationalWarning.cancelMsgYear, let navAreaEnum = NavigationalWarningNavArea(rawValue: cancelNavArea){
                        Property(property: "Cancelled By", value: "\(navAreaEnum.description) \(cancelMsgNumber)/\(cancelMsgYear)")
                    }
                    NavigationalWarningActionBar(navigationalWarning: navigationalWarning)
                }
                .padding(.all, 16)
                .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                .modifier(CardModifier())
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            Section("Text") {
                Text(navigationalWarning.text ?? "")
                    .multilineTextAlignment(.leading)
                    .font(Font(scheme.containerScheme.typographyScheme.body2))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                    .opacity(0.6)
                    .frame(maxWidth:.infinity, alignment: .leading)
                    .padding(.all, 16)
                    .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                    .modifier(CardModifier())
            }
            .padding(.bottom, -20)
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.grouped)
        .padding(.top, -24)
    }
}

struct NavigationalWarningDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let navigationalWarning = try? context.fetchFirst(NavigationalWarning.self)
        NavigationalWarningDetailView(navigationalWarning: navigationalWarning!)
    }
}
