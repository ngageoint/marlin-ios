//
//  NavigationalWarningAreaUnreadBadge.swift
//  Marlin
//
//  Created by Daniel Barela on 6/28/22.
//

import SwiftUI

struct NavigationalWarningAreaUnreadBadge: View { 
    var unreadCount: Int
    var body: some View {
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
    }
}
