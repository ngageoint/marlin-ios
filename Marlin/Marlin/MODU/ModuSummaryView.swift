//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var modu: Modu
    var showMoreDetails: Bool = false
    
    init(modu: Modu, showMoreDetails: Bool = false) {
        self.modu = modu
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(modu.dateString ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.45)
            Text("\(modu.name ?? "")")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
            Text("Rig Status: \(modu.rigStatus ?? "")")
                .lineLimit(1)
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            Text("Special Status: \(modu.specialStatus ?? "")")
                .lineLimit(1)
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            ModuActionBar(modu: modu, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}

struct ModuSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let modu = try? context.fetchFirst(Modu.self)
        return ModuSummaryView(modu: modu!)
    }
}
