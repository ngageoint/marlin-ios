//
//  NavigationalWarningAreaUnreadBadge.swift
//  Marlin
//
//  Created by Daniel Barela on 6/28/22.
//

import SwiftUI

struct NavigationalWarningAreaUnreadBadge: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    @AppStorage<String> var lastSeen: String
    var warnings: [NavigationalWarning]
    
    init(navArea: String, warnings: [NavigationalWarning]) {
        self._lastSeen = AppStorage(wrappedValue: "", "lastSeen-\(navArea)")
        self.warnings = warnings
    }

    var body: some View {
        
        if let lastSeenIndex = warnings.firstIndex(where: { warning in
            warning.primaryKey == lastSeen
        }) {
            let unreadCount = warnings.distance(from: warnings.startIndex, to: lastSeenIndex)
            if unreadCount != 0 {
                Text("\(unreadCount)")
                    .font(Font(scheme.containerScheme.typographyScheme.overline))
                    .monospacedDigit()
                    .bold()
                    .padding(.all, 4)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        } else {
            Text("\(warnings.count)")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .monospacedDigit()
                .bold()
                .padding(.all, 4)
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

struct NavigationalWarningAreaUnreadBadge_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {

        var body: some View {
            NavigationalWarningAreaUnreadBadge(navArea: "P", warnings:[])
        }
    }
}
