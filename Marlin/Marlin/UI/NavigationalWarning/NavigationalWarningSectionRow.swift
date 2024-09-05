//
//  NavigationalWarningSectionRow.swift
//  Marlin
//
//  Created by Daniel Barela on 5/24/23.
//

import SwiftUI

struct NavigationalWarningSection: Hashable {
    static func == (lhs: NavigationalWarningSection, rhs: NavigationalWarningSection) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var id: String
    var warnings: [NavigationalWarning]
}

struct NavigationalWarningSectionRow: View {
    var navAreaInformation: NavigationalAreaInformation
//    var section: SectionedFetchResults<String, NavigationalWarning>.Element
    var mapName: String?
    
    var body: some View {
        NavigationLink(value: NavigationalWarningRoute.areaList(navArea: navAreaInformation.navArea.name)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NavigationalWarningNavArea.fromId(id: navAreaInformation.navArea.name)?.display ?? "")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Text("\(navAreaInformation.total) Active")
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                }
                Spacer()
                NavigationalWarningAreaUnreadBadge(unreadCount: navAreaInformation.unread)
            }
        }
        .isDetailLink(false)
        .accessibilityElement(children: .contain)
        .padding(.leading, 8)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(
            HStack {
                Rectangle()
                    .fill(Color(
                        NavigationalWarningNavArea.fromId(id: navAreaInformation.navArea.name)?.color ?? UIColor.clear
                    ))
                    .frame(maxWidth: 6, maxHeight: .infinity)
                Spacer()
            }
            .padding([.leading, .top, .bottom], -8)
        )
    }
}
