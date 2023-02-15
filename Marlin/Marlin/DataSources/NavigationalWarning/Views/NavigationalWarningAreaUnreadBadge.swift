//
//  NavigationalWarningAreaUnreadBadge.swift
//  Marlin
//
//  Created by Daniel Barela on 6/28/22.
//

import SwiftUI

struct NavigationalWarningAreaUnreadBadge: View {    
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
                    .font(Font.overline)
                    .monospacedDigit()
                    .bold()
                    .padding(.all, 4)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(unreadCount) Unread")
            }
        } else {
            Text("\(warnings.count)")
                .font(Font.overline)
                .monospacedDigit()
                .bold()
                .padding(.all, 4)
                .background(.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(warnings.count) Unread")
        }
    }
}
