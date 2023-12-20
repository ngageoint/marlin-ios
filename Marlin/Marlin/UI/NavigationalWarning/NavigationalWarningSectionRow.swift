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
    var section: SectionedFetchResults<String, NavigationalWarning>.Element
    var mapName: String?
    @Binding var path: NavigationPath
    
    var body: some View {
        NavigationLink(value: NavigationalWarningSection(id: section.id, warnings: [NavigationalWarning](section))) {
            HStack {
                VStack(alignment: .leading) {
                    Text(NavigationalWarningNavArea.fromId(id: section.id)?.display ?? "")
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Text("\(section.count) Active")
                        .font(Font.caption)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                }
                Spacer()
                NavigationalWarningAreaUnreadBadge(navArea: section.id, warnings: [NavigationalWarning](section))
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
                    .fill(Color(NavigationalWarningNavArea.fromId(id: section.id)?.color ?? UIColor.clear))
                    .frame(maxWidth: 6, maxHeight: .infinity)
                Spacer()
            }
            .padding([.leading, .top, .bottom], -8)
        )
    }
}
