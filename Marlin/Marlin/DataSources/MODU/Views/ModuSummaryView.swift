//
//  ModuSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

struct ModuSummaryView: View {
        
    var modu: Modu
    var showMoreDetails: Bool = false
    
    init(modu: Modu, showMoreDetails: Bool = false) {
        self.modu = modu
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(modu.dateString ?? "")
                .overline()
            Text("\(modu.name ?? "")")
                .primary()
            Text("Rig Status: \(modu.rigStatus ?? "")")
                .lineLimit(1)
                .secondary()
            Text("Special Status: \(modu.specialStatus ?? "")")
                .lineLimit(1)
                .secondary()
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
