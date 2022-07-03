//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI

struct NavigationalWarningSummaryView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var navigationalWarning: NavigationalWarning
    
    init(navigationalWarning: NavigationalWarning) {
        self.navigationalWarning = navigationalWarning
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navigationalWarning.dateString ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.45)
            Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
            Text("\(navigationalWarning.text ?? "")")
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            NavigationalWarningActionBar(navigationalWarning: navigationalWarning)
        }
    }
}

struct NavigationalWarningSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let navigationalWarning = try? context.fetchFirst(NavigationalWarning.self)
        NavigationalWarningSummaryView(navigationalWarning: navigationalWarning!)
    }
}
