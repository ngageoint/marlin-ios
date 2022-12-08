//
//  SettingsCell.swift
//  Marlin
//
//  Created by Daniel Barela on 9/2/22.
//

import SwiftUI

struct AboutCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "info.circle")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("About")
                    .font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.87)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                NotificationCenter.default.post(name: .SwitchTabs, object: "settings")
            }
            .padding([.leading, .top, .bottom, .trailing], 16)
            Divider()
        }
        
        .background(Color.surfaceColor)
    }
}
